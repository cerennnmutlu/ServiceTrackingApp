//
//  AuthService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//
import Foundation

protocol AuthServicing {
    func login(email: String, password: String) async throws
    func register(fullName: String, username: String, email: String, password: String) async throws
}

final class AuthService: AuthServicing {
    private let client: APIClient
    private let tokenStore: TokenStore
    private let appState: AppState

    init(client: APIClient = APIClient(),
         tokenStore: TokenStore = KeychainTokenStore.shared,
         appState: AppState) {
        self.client = client
        self.tokenStore = tokenStore
        self.appState = appState
    }

    // MARK: - Register

    /// Yeni kayıt olan kullanıcılar için role ID 3
    private func getDefaultRoleId() async -> Int {
        return 3 // Yeni kayıt olanlar için sabit role ID
    }

    func register(fullName: String, username: String, email: String, password: String) async throws {
        let roleId = await getDefaultRoleId()
        let req = RegisterRequest(fullName: fullName,
                                  username: username,
                                  email: email,
                                  password: password,
                                  roleID: roleId)

        var ep = Endpoint(path: "api/Auth/register", method: .POST)
        ep.body = try req.toJSONData()

        do {
            let response: RegisterResponse = try await client.send(ep)
            print("✅ Registration successful: \(response.message ?? "No message")")
            if let user = response.user {
                print("✅ User created with ID: \(user.userID)")
            }
        } catch {
            print("❌ Registration failed: \(error)")
            if let apiError = error as? APIError {
                print("❌ API Error details: \(apiError)")
            }
            throw error
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async throws {
        let usernameOrEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = try JSONEncoder().encode(["username": usernameOrEmail, "password": password])

        var ep = Endpoint(path: "api/Auth/login", method: .POST)
        ep.body = body

        let res: LoginResponse = try await client.send(ep)
        tokenStore.token = res.token
        await MainActor.run { appState.isAuthenticated = true }
    }
}
