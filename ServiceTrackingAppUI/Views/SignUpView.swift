//
//  SignUpView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

// Views/SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState

    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRoleID: Int? = nil

    @State private var roles: [Role] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Your Info")) {
                TextField("Full name", text: $fullName)
                    .textInputAutocapitalization(.words)
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password (min 6 chars)", text: $password)
            }

            Section(header: Text("Role")) {
                if roles.isEmpty {
                    HStack { Text("Roles"); Spacer(); Text("loading…").foregroundStyle(.secondary) }
                } else {
                    Picker("Role", selection: Binding(
                        get: { selectedRoleID ?? roles.first?.id },
                        set: { selectedRoleID = $0 }
                    )) {
                        ForEach(roles) { r in
                            Text(r.roleName).tag(r.id as Int?)
                        }
                    }
                }
            }

            Section {
                Button(action: register) {
                    if isLoading { ProgressView() }
                    else { Text("Create Account").bold() }
                }
                .disabled(isLoading || !isFormValid)
            }
        }
        .navigationTitle("Sign Up")
        .onAppear { loadRoles() }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private var isFormValid: Bool {
        !fullName.isEmpty && !username.isEmpty && !email.isEmpty && password.count >= 6
    }

    // MARK: - Networking

    private func loadRoles() {
        Task {
            do {
                // sendList yerine send kullanıyoruz (roles düz dizi dönüyor)
                let rolesArr: [Role] = try await APIClient().send(
                    Endpoint(path: "/api/Auth/roles", method: .GET)
                )
                await MainActor.run {
                    self.roles = rolesArr
                    if selectedRoleID == nil { selectedRoleID = rolesArr.first?.id }
                }
            } catch {
                // Rolleri çekemezsek, backend default kabul ediyorsa 1’e düş
                await MainActor.run {
                    self.roles = []
                    self.selectedRoleID = self.selectedRoleID ?? 1
                }
            }
        }
    }

    private func register() {
        // ❗️guard let değil -> doğrudan let (artık optional değil)
        let roleID: Int = selectedRoleID ?? roles.first?.id ?? 1
        isLoading = true; errorMessage = nil

        Task {
            do {
                struct RegisterRequest: Encodable {
                    let fullName: String
                    let username: String
                    let email: String
                    let password: String
                    let roleID: Int
                }
                struct RegisterResponse: Decodable {
                    let message: String?
                    let user: UserInfo?
                }

                let body = try RegisterRequest(
                    fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password,
                    roleID: roleID
                ).toJSONData()

                _ = try await APIClient().send(
                    Endpoint(path: "/api/Auth/register", method: .POST, body: body)
                ) as RegisterResponse

                // Otomatik login
                try await AuthService(appState: appState).login(email: username, password: password)
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}
