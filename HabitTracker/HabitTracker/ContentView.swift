//
//  ContentView.swift
//  HabitTracker
//
//  Created by Sahasra Kalwala on 12/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentUser: User? = nil
    @State private var isLoadingUser = true

    var body: some View {
        if isLoadingUser {
            ProgressView("Loading...")
                .onAppear {
                    loadCurrentUser()
                }
        } else if let user = currentUser {
            MainTabView(user: user, onLogout: logout)
        } else {
            UserManagementView(currentUser: $currentUser)
        }
    }

    private func loadCurrentUser() {
        // Try to load saved user ID
        if let userId = UserDefaults.standard.value(forKey: "currentUserId") as? Int {
            NetworkManager.shared.getUser(userId: userId) { user in
                DispatchQueue.main.async {
                    currentUser = user
                    isLoadingUser = false
                }
            }
        } else {
            isLoadingUser = false
        }
    }

    private func logout() {
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        currentUser = nil
    }
}

struct MainTabView: View {
    let user: User
    let onLogout: () -> Void

    var body: some View {
        TabView {
            DailyHabitsView(user: user)
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Today")
                }

            ProfileView(user: user, onLogout: onLogout)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
    }
}

struct ProfileView: View {
    let user: User
    let onLogout: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)

                Text(user.name ?? "Anonymous User")
                    .font(.title)
                    .fontWeight(.bold)

                Text("User ID: \(user.id)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: onLogout) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .padding(.top, 50)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}