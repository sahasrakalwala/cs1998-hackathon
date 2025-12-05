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

// UserHabit join table representation
struct UserHabit: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let habit_id: Int
}

// Daily habit completion model
struct DailyHabitCompletion: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let habit_id: Int
    let date: String // YYYY-MM-DD format
}

// Response model for daily habits endpoint
struct DailyHabit: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    var completed: Bool
}
