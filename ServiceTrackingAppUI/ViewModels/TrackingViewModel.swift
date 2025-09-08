//
//  TrackingViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

@MainActor
final class TrackingViewModel: ObservableObject {
    @Published var items: [Tracking] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedTracking: Tracking?
    @Published var trackingsByVehicle: [Tracking] = []
    @Published var trackingsByDate: [Tracking] = []

    private let service: TrackingServicing
    init(service: TrackingServicing) { self.service = service }

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
            selectedTracking = try await service.getById(id: id)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func loadByVehicle(vehicleId: Int) async {
        isLoading = true; error = nil
        do {
            trackingsByVehicle = try await service.getByVehicle(vehicleId: vehicleId)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func loadByDate(date: String) async {
        isLoading = true; error = nil
        do {
            trackingsByDate = try await service.getByDate(date: date)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func create(_ request: CreateTrackingRequest) async -> Bool {
        isLoading = true
        
        do {
            let newTracking = try await service.create(request)
            items.append(newTracking)
            isLoading = false
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func update(id: Int, _ request: UpdateTrackingRequest) async -> Bool {
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
    
    func clearSelectedTracking() {
        selectedTracking = nil
    }
}