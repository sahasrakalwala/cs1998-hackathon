import SwiftUI

struct DailyHabitsView: View {
    let user: User
    @State private var dailyHabits: [DailyHabit] = []
    @State private var isLoading = false
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack {
                // Date selector
                HStack {
                    Button(action: { showDatePicker = true }) {
                        HStack {
                            Text(formattedDate(selectedDate))
                                .font(.headline)
                            Image(systemName: "calendar")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    Spacer()
                    Text("Daily Habits")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)

                if isLoading {
                    ProgressView("Loading habits...")
                        .padding()
                } else if dailyHabits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.green)
                        Text("No habits for today")
                            .font(.title2)
                        Text("Add some habits to get started!")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 100)
                } else {
                    ScrollView { // Scrollable view requirement
                        LazyVStack(spacing: 16) {
                            ForEach(dailyHabits) { habit in
                                DailyHabitRow(
                                    habit: habit,
                                    onToggle: { toggleHabitCompletion(habit) }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showDatePicker) {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .onChange(of: selectedDate) {
                        loadDailyHabits()
                        showDatePicker = false
                    }
            }
            .onAppear {
                loadDailyHabits()
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func loadDailyHabits() {
        isLoading = true
        let dateString = dateFormatter.string(from: selectedDate)

        NetworkManager.shared.getDailyHabits(userId: user.id, date: dateString) { habits in
            DispatchQueue.main.async {
                isLoading = false
                if let habits = habits {
                    dailyHabits = habits
                }
            }
        }
    }

    private func toggleHabitCompletion(_ habit: DailyHabit) {
        let dateString = dateFormatter.string(from: selectedDate)

        if habit.completed {
            // Unmark as complete
            NetworkManager.shared.unmarkHabitComplete(userId: user.id, habitId: habit.id, date: dateString) { success in
                if success {
                    DispatchQueue.main.async {
                        if let index = dailyHabits.firstIndex(where: { $0.id == habit.id }) {
                            dailyHabits[index].completed.toggle()
                        }
                    }
                }
            }
        } else {
            // Mark as complete
            NetworkManager.shared.markHabitComplete(userId: user.id, habitId: habit.id, date: dateString) { success in
                if success {
                    DispatchQueue.main.async {
                        if let index = dailyHabits.firstIndex(where: { $0.id == habit.id }) {
                            dailyHabits[index].completed.toggle()
                        }
                    }
                }
            }
        }
    }
}

struct DailyHabitRow: View {
    let habit: DailyHabit
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                    .strikethrough(habit.completed)
                if let description = habit.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .strikethrough(habit.completed)
                }
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: habit.completed ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(habit.completed ? .green : .gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
