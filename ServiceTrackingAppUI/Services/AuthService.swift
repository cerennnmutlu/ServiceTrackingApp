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
    func getProfile() async throws -> User
    func updateProfile(fullName: String, username: String, email: String) async throws -> User
    func changePassword(currentPassword: String, newPassword: String) async throws
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

    // MARK: - Profile

    func getProfile() async throws -> User {
        let ep = Endpoint(path: "api/Auth/profile", method: .GET)
        let user: User = try await client.send(ep)
        return user
    }
    
    func updateProfile(fullName: String, username: String, email: String) async throws -> User {
        let req = UpdateProfileRequest(fullName: fullName, username: username, email: email)
        
        var ep = Endpoint(path: "api/Auth/profile", method: .PUT)
        ep.body = try req.toJSONData()
        
        do {
            let response: UpdateProfileResponse = try await client.send(ep)
            print("✅ Profile update successful: \(response.message ?? "No message")")
            
            // Return updated user or fetch fresh profile
            if let updatedUser = response.user {
                return updatedUser
            } else {
                // If response doesn't include user, fetch fresh profile
                return try await getProfile()
            }
        } catch {
            print("❌ Profile update failed: \(error)")
            if let apiError = error as? APIError {
                print("❌ API Error details: \(apiError)")
            }
            throw error
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        let req = ChangePasswordRequest(currentPassword: currentPassword, newPassword: newPassword)
        
        var ep = Endpoint(path: "api/Auth/change-password", method: .PUT)
        ep.body = try req.toJSONData()
        
        do {
            let response: ChangePasswordResponse = try await client.send(ep)
            print("✅ Password change successful: \(response.message ?? "No message")")
        } catch {
            print("❌ Password change failed: \(error)")
            if let apiError = error as? APIError {
                print("❌ API Error details: \(apiError)")
            }
            throw error
        }
    }
}
