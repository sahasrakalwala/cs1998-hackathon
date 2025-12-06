import Foundation

// User model
struct User: Codable, Identifiable {
    let id: Int
    let name: String?
}

// Global Habit model (available to all users)
struct Habit: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
}

// Response model for daily habits endpoint
struct DailyHabit: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    var completed: Bool
}

// Response model for habit streak
struct HabitStreak: Codable {
    let habit_id: Int
    let current_streak: Int
    let longest_streak: Int
}
