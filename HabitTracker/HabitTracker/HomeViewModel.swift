//
//  HomeViewModel.swift
//  HabitTracker
//
//  Created by Sahasra Kalwala on 12/5/25.
//
import SwiftUI
internal import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var habits: [Habit] = []
    @Published var completedHabitIDs: Set<Int> = []
    @Published var habitStreaks: [Int: Int] = [:] // Maps Habit ID to Streak Count
    @Published var isLoading = false
    
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - User Actions
    
    func login(name: String) {
        isLoading = true
        Task {
            do {
                let user = try await NetworkManager.shared.createUser(name: name)
                self.currentUser = user
                await fetchData()
            } catch {
                print("Login failed: \(error)")
            }
            isLoading = false
        }
    }
    
    func fetchData() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let fetchedHabits = try await NetworkManager.shared.getUserHabits(userId: userId)
            self.habits = fetchedHabits
            
            let completions = try await NetworkManager.shared.getDailyCompletions(userId: userId, date: todayString)
            self.completedHabitIDs = Set(completions.map { $0.id })
            
            for habit in fetchedHabits {
                let streakData = try await NetworkManager.shared.getStreak(userId: userId, habitId: habit.id)
                self.habitStreaks[habit.id] = streakData.current_streak
            }
            
        } catch {
            print("Fetch data failed: \(error)")
        }
    }
    
    func toggleHabit(_ habit: Habit) {
            guard let userId = currentUser?.id else { return }
            let isComplete = completedHabitIDs.contains(habit.id)
            
            if isComplete {
                completedHabitIDs.remove(habit.id)
            } else {
                completedHabitIDs.insert(habit.id)
            }
            
            Task {
                do {
                    if isComplete {
                        _ = try await NetworkManager.shared.unmarkComplete(userId: userId, habitId: habit.id, date: todayString)
                    } else {
                        _ = try await NetworkManager.shared.markComplete(userId: userId, habitId: habit.id, date: todayString)
                    }
                    let newStreak = try await NetworkManager.shared.getStreak(userId: userId, habitId: habit.id)
                    self.habitStreaks[habit.id] = newStreak.current_streak
                } catch {
                    print("Toggle failed: \(error)")
                    if isComplete { completedHabitIDs.insert(habit.id) }
                    else { completedHabitIDs.remove(habit.id) }
                }
            }
        }
    
    func createHabit(title: String, description: String) {
        Task {
            do {
                _ = try await NetworkManager.shared.createHabit(title: title, description: description)
                await fetchData()
            } catch {
                print("Create failed: \(error)")
            }
        }
    }
}
