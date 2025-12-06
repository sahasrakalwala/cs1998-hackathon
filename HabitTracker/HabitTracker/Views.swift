//
//  Views.swift
//  HabitTracker
//
//  Created by Sahasra Kalwala on 12/5/25.
//
import SwiftUI

// MARK: - Root View
struct ContentView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        if viewModel.currentUser == nil {
            LoginView()
                .environmentObject(viewModel)
        } else {
            HomeView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var username = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Habit Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Enter Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .textInputAutocapitalization(.never)
            
            Button(action: {
                viewModel.login(name: username)
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Start Tracking")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .disabled(username.isEmpty)
        }
    }
}

// MARK: - Home View (Daily List)
struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.habits) { habit in
                        HabitRow(habit: habit)
                    }
                }
                .padding()
            }
            .navigationTitle("Today's Habits")
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddHabitView()
            }
            .refreshable {
                await viewModel.fetchData()
            }
        }
    }
}

// MARK: - Habit Row Component
struct HabitRow: View {
    let habit: Habit
    @EnvironmentObject var viewModel: HomeViewModel
    
    var isCompleted: Bool {
        viewModel.completedHabitIDs.contains(habit.id)
    }
    
    var streakCount: Int {
        viewModel.habitStreaks[habit.id] ?? 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                    .strikethrough(isCompleted, color: .gray)
                    .foregroundColor(isCompleted ? .gray : .primary)
                
                if let desc = habit.description, !desc.isEmpty {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("🔥 Streak: \(streakCount)")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    viewModel.toggleHabit(habit)
                }
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundColor(isCompleted ? .green : .gray)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Add Habit Sheet
struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: HomeViewModel
    
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Habit Title", text: $title)
                    TextField("Description (Optional)", text: $description)
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createHabit(title: title, description: description)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
