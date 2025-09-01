//
//  ProfileViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by AI on 29.08.2025.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: String?
    @Published var notificationsEnabled = false
    @Published var isUpdatingProfile = false
    @Published var isChangingPassword = false
    @Published var successMessage: String?

    private let authService: AuthServicing
    
    init(authService: AuthServicing) {
        self.authService = authService
    }
    
    convenience init(appState: AppState) {
        let service = AuthService(appState: appState)
        self.init(authService: service)
    }
    
    convenience init() {
        // Default init with a placeholder AppState - should be used carefully
        let service = AuthService(appState: AppState())
        self.init(authService: service)
    }

    func loadMe() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let userData = try await authService.getProfile()
                await MainActor.run {
                    self.user = userData
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func updateProfile(fullName: String, username: String, email: String) {
        isUpdatingProfile = true
        error = nil
        successMessage = nil
        
        Task {
            do {
                let updatedUser = try await authService.updateProfile(fullName: fullName, username: username, email: email)
                await MainActor.run {
                    self.user = updatedUser
                    self.isUpdatingProfile = false
                    self.successMessage = "Profile updated successfully!"
                }
            } catch {
                await MainActor.run {
                    self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    self.isUpdatingProfile = false
                }
            }
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) {
        isChangingPassword = true
        error = nil
        successMessage = nil
        
        Task {
            do {
                try await authService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                await MainActor.run {
                    self.isChangingPassword = false
                    self.successMessage = "Password changed successfully!"
                }
            } catch {
                await MainActor.run {
                    self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    self.isChangingPassword = false
                }
            }
        }
    }
    
    func clearMessages() {
        error = nil
        successMessage = nil
    }
}


