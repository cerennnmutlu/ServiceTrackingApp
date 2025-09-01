//
//  VehiclesViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

@MainActor
final class VehiclesViewModel: ObservableObject {
    @Published var items: [ServiceVehicle] = []
    @Published var isLoading = false
    @Published var error: String?

    private let service: VehicleServicing
    init(service: VehicleServicing) { self.service = service }

    func load() async {
        isLoading = true; error = nil
        do {
            items = try await service.list()
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func loadSync() {
        Task {
            await load()
        }
    }
}