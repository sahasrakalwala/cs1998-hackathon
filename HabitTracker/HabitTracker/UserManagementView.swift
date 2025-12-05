import SwiftUI

struct UserManagementView: View {
    @Binding var currentUser: User?
    @State private var userName = ""
    @State private var isCreatingUser = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Habit Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)

                Text("Create your profile to start tracking habits")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                VStack(spacing: 16) {
                    TextField("Enter your name (optional)", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button(action: createUser) {
                        if isCreatingUser {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Create Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isCreatingUser)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func createUser() {
        isCreatingUser = true
        let name = userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : userName

        NetworkManager.shared.createUser(name: name) { user in
            DispatchQueue.main.async {
                isCreatingUser = false
                if let user = user {
                    currentUser = user
                    // Save user ID to UserDefaults for persistence
                    UserDefaults.standard.set(user.id, forKey: "currentUserId")
                } else {
                    showError = true
                    errorMessage = "Failed to create user. Please try again."
                }
            }
        }
    }
}
