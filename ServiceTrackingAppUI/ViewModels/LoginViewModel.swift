//
//  LoginViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?

    private let auth: AuthServicing

    init(auth: AuthServicing) { self.auth = auth }

    func login() {
        isLoading = true; error = nil
        Task {
            do {
                try await auth.login(email: email, password: password)
            } catch {
                self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
