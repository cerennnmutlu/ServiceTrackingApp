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
    
    func create(_ request: CreateVehicleRequest) async -> Bool {
        isLoading = true; error = nil
        do {
            _ = try await service.create(request)
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return false
        }
        isLoading = false
    }
    
    func update(id: Int, _ request: UpdateVehicleRequest) async -> Bool {
        isLoading = true; error = nil
        do {
            _ = try await service.update(id: id, request)
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return false
        }
        isLoading = false
    }
    
    func delete(id: Int) async -> Bool {
        isLoading = true; error = nil
        do {
            try await service.delete(id: id)
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return false
        }
        isLoading = false
    }
}