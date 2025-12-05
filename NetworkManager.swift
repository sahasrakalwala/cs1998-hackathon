import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    let baseURL = "http://127.0.0.1:5000"

    // MARK: - Create User
    func createUser(name: String?, completion: @escaping (User?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/users") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["name": name ?? ""]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Error creating user: \(error?.localizedDescription ?? "Unknown")")
                    completion(nil)
                    return
                }

                let user = try? JSONDecoder().decode(User.self, from: data)
                completion(user)
            }
        }.resume()
    }

    // MARK: - Get User
    func getUser(userId: Int, completion: @escaping (User?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Error fetching user: \(error?.localizedDescription ?? "Unknown")")
                    completion(nil)
                    return
                }

                let user = try? JSONDecoder().decode(User.self, from: data)
                completion(user)
            }
        }.resume()
    }

    // MARK: - Create Global Habit
    func createGlobalHabit(title: String, description: String?, completion: @escaping (Habit?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/habits") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = ["title": title]
        if let description = description {
            body["description"] = description
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Error creating habit: \(error?.localizedDescription ?? "Unknown")")
                    completion(nil)
                    return
                }

                let habit = try? JSONDecoder().decode(Habit.self, from: data)
                completion(habit)
            }
        }.resume()
    }

    // MARK: - List Global Habits
    func listGlobalHabits(completion: @escaping ([Habit]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/habits") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Error fetching habits: \(error?.localizedDescription ?? "Unknown")")
                    completion(nil)
                    return
                }

                let habits = try? JSONDecoder().decode([Habit].self, from: data)
                completion(habits)
            }
        }.resume()
    }

    // MARK: - Get User Habits
    func getUserHabits(userId: Int, completion: @escaping ([Habit]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/habits") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Error fetching user habits: \(error?.localizedDescription ?? "Unknown")")
                    completion(nil)
                    return
                }

                let habits = try? JSONDecoder().decode([Habit].self, from: data)
                completion(habits)
            }
        }.resume()
    }

    // MARK: - Get Daily Habits
    func getDailyHabits(userId: Int, date: String, completion: @escaping ([DailyHabit]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/habits/daily?date=\(date)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Error fetching daily habits: \(error?.localizedDescription ?? "Unknown")")
                    completion(nil)
                    return
                }

                let dailyHabits = try? JSONDecoder().decode([DailyHabit].self, from: data)
                completion(dailyHabits)
            }
        }.resume()
    }

    // MARK: - Mark Habit Complete
    func markHabitComplete(userId: Int, habitId: Int, date: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/habits/\(habitId)/complete?date=\(date)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }

    // MARK: - Unmark Habit Complete
    func unmarkHabitComplete(userId: Int, habitId: Int, date: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/habits/\(habitId)/complete?date=\(date)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }

}
