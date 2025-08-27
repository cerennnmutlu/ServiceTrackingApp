//
//  AuthService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol AuthServicing {
    func login(email: String, password: String) async throws
}

final class AuthService: AuthServicing {
    private let client: APIClient
    private var tokenStore: TokenStore
    private let appState: AppState

    init(client: APIClient = APIClient(),
         tokenStore: TokenStore = KeychainTokenStore.shared,
         appState: AppState) {
        self.client = client
        self.tokenStore = tokenStore
        self.appState = appState
    }

    func login(email: String, password: String) async throws {
        let u = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = try JSONEncoder().encode(["username": u, "password": password])
        let ep = Endpoint(path: "/api/Auth/login", method: .POST, body: body)
        let res: LoginResponse = try await client.send(ep)
        tokenStore.token = res.token
        await MainActor.run { appState.isAuthenticated = true }
    }

}

