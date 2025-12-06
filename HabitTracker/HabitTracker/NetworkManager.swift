import Foundation

// Custom Error to handle API failures cleanly
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError
}

class NetworkManager {
    static let shared = NetworkManager()

    let baseURL = "http://34.86.208.250"

    // MARK: - Create User
    func createUser(name: String?) async throws -> User {
        guard let url = URL(string: "\(baseURL)/api/users") else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["name": name ?? ""]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw NetworkError.serverError
        }

        return try JSONDecoder().decode(User.self, from: data)
    }

    // MARK: - Get User
    func getUser(userId: Int) async throws -> User {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)") else { throw NetworkError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }

        return try JSONDecoder().decode(User.self, from: data)
    }

    // MARK: - Create Global Habit
    func createHabit(title: String, description: String?) async throws -> Habit {
        guard let url = URL(string: "\(baseURL)/api/habits") else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = ["title": title]
        if let description = description {
            body["description"] = description
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw NetworkError.serverError
        }

        return try JSONDecoder().decode(Habit.self, from: data)
    }

    // MARK: - Get User Habits
    func getUserHabits(userId: Int) async throws -> [Habit] {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/habits") else { throw NetworkError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }

        return try JSONDecoder().decode([Habit].self, from: data)
    }

    // MARK: - Get Daily Completions
    func getDailyCompletions(userId: Int, date: String) async throws -> [DailyHabit] {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/habits/daily?date=\(date)") else { throw NetworkError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }

        return try JSONDecoder().decode([DailyHabit].self, from: data)
    }

    // MARK: - Mark Habit Complete
    func markComplete(userId: Int, habitId: Int, date: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/habits/\(habitId)/complete?date=\(date)") else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            return true
        }
        return false
    }

    // MARK: - Unmark Habit Complete
    func unmarkComplete(userId: Int, habitId: Int, date: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/habits/\(habitId)/complete?date=\(date)") else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            return true
        }
        return false
    }

    // MARK: - Get Habit Streak
    // Renamed to match ViewModel call: getStreak
    func getStreak(userId: Int, habitId: Int) async throws -> HabitStreak {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/habits/\(habitId)/streak") else { throw NetworkError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }

        return try JSONDecoder().decode(HabitStreak.self, from: data)
    }
}
