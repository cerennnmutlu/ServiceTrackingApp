//
//  DriversViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

@MainActor
final class DriversViewModel: ObservableObject {
    @Published var items: [Driver] = []
    @Published var isLoading = false
    @Published var error: String?

    private let service: DriverServicing
    init(service: DriverServicing) { self.service = service }

    func load() {
        isLoading = true; error = nil
        Task {
            do {
                items = try await service.list()
            } catch {
                self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}
