//
//  VehicleShiftAssignmentViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

@MainActor
final class VehicleShiftAssignmentViewModel: ObservableObject {
    @Published var items: [VehicleShiftAssignment] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedAssignment: VehicleShiftAssignment?
    @Published var assignmentsByVehicle: [VehicleShiftAssignment] = []
    @Published var assignmentsByShift: [VehicleShiftAssignment] = []
    @Published var assignmentsByDate: [VehicleShiftAssignment] = []
    @Published var todayAssignments: [VehicleShiftAssignment] = []

    private let service: VehicleShiftAssignmentServicing
    init(service: VehicleShiftAssignmentServicing) { self.service = service }

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
    
    func loadByShift(shiftId: Int) async {
        isLoading = true; error = nil
        do {
            assignmentsByShift = try await service.getByShift(shiftId: shiftId)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func loadByDate(date: String) async {
        isLoading = true; error = nil
        do {
            assignmentsByDate = try await service.getByDate(date: date)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func loadTodayAssignments() async {
        isLoading = true; error = nil
        do {
            todayAssignments = try await service.getTodayAssignments()
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func create(_ request: CreateVehicleShiftAssignmentRequest) async -> Bool {
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
    
    func createBulkAssignments(_ request: CreateBulkAssignmentsRequest) async -> Bool {
        isLoading = true
        
        do {
            let response = try await service.createBulkAssignments(request)
            if response.error == nil {
                // Refresh the list after successful bulk creation
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
    
    func update(id: Int, _ request: UpdateVehicleShiftAssignmentRequest) async -> Bool {
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