//
//  VehicleDriverAssignmentViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

@MainActor
final class VehicleDriverAssignmentViewModel: ObservableObject {
    @Published var items: [VehicleDriverAssignment] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedAssignment: VehicleDriverAssignment?
    @Published var assignmentsByVehicle: [VehicleDriverAssignment] = []
    @Published var assignmentsByDriver: [VehicleDriverAssignment] = []
    @Published var vehiclePlateNumbers: [Int: String] = [:]

    private let service: VehicleDriverAssignmentServicing
    init(service: VehicleDriverAssignmentServicing) { self.service = service }

    func load() async {
        isLoading = true; error = nil
        do {
            items = try await service.list()
            await loadVehiclePlateNumbers()
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    private func loadVehiclePlateNumbers() async {
        let vehicleService = VehicleService()
        let uniqueVehicleIds = Set(items.compactMap { $0.serviceVehicleID })
        
        for vehicleId in uniqueVehicleIds {
            do {
                if let vehicle = try await vehicleService.getById(id: vehicleId) {
                    vehiclePlateNumbers[vehicleId] = vehicle.plateNumber
                }
            } catch {
                // Hata durumunda sessizce devam et
                continue
            }
        }
    }
    
    func loadSync() {
        Task {
            await load()
        }
    }
    
    func loadById(id: Int) async {
        isLoading = true; error = nil
        do {
            selectedAssignment = try await service.getById(id: id)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func loadByVehicle(vehicleId: Int) async {
        isLoading = true; error = nil
        do {
            assignmentsByVehicle = try await service.getByVehicle(vehicleId: vehicleId)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func loadByDriver(driverId: Int) async {
        isLoading = true; error = nil
        do {
            assignmentsByDriver = try await service.getByDriver(driverId: driverId)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func create(_ request: CreateVehicleDriverAssignmentRequest) async -> Bool {
        isLoading = true
        
        do {
            let newAssignment = try await service.create(request)
            items.append(newAssignment)
            isLoading = false
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func update(id: Int, _ request: UpdateVehicleDriverAssignmentRequest) async -> Bool {
        isLoading = true
        
        do {
            let response = try await service.update(id: id, request)
            if response.error == nil {
                // Refresh the list after successful update
                await load()
                isLoading = false
                return true
            } else {
                self.error = response.error
                isLoading = false
                return false
            }
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func delete(id: Int) async {
        isLoading = true
        
        do {
            try await service.delete(id: id)
            items.removeAll { $0.id == id }
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearError() {
        error = nil
    }
    
    func clearSelectedAssignment() {
        selectedAssignment = nil
    }
}