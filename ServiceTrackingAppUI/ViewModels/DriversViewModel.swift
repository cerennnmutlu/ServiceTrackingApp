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
    
    func create(_ request: CreateDriverRequest) async -> Bool {
        isLoading = true
        
        do {
            let newDriver = try await service.create(request)
            items.append(newDriver)
            isLoading = false
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func update(id: Int, _ request: UpdateDriverRequest) async -> Bool {
        isLoading = true
        
        do {
            _ = try await service.update(id: id, request)
            if let index = items.firstIndex(where: { $0.id == id }) {
                // Update local model with new data
                items[index] = Driver(
                    id: id,
                    fullName: request.fullName,
                    phone: request.phone,
                    status: request.status,
                    createdAt: items[index].createdAt,
                    updatedAt: Date(),
                    vehicleDriverAssignments: items[index].vehicleDriverAssignments
                )
            }
            isLoading = false
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func delete(id: Int) async {
        do {
            try await service.delete(id: id)
            items.removeAll { $0.id == id }
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
