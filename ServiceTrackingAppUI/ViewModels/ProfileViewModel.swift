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

    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func loadMe() {
        isLoading = true; error = nil
        Task {
            do {
                var ep = Endpoint(path: "api/Auth/me", method: .GET)
                let envelope: ApiEnvelope<User> = try await client.send(ep)
                self.user = envelope.data
            } catch {
                self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}


