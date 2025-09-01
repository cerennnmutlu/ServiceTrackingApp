//
//  ShiftsViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

@MainActor
final class ShiftsViewModel: ObservableObject {
    @Published var items: [Shift] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var isProcessing = false

    private let service: ShiftServicing
    init(service: ShiftServicing) { self.service = service }

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
    
    func create(_ request: CreateShiftRequest) async -> Bool {
        isProcessing = true; error = nil
        do {
            let newShift = try await service.create(request)
            items.append(newShift)
            isProcessing = false
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isProcessing = false
            return false
        }
    }
    
    func update(id: Int, _ request: UpdateShiftRequest) async -> Bool {
        isProcessing = true; error = nil
        do {
            let updatedShift = try await service.update(id: id, request)
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index] = updatedShift
            }
            isProcessing = false
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isProcessing = false
            return false
        }
    }
    
    func delete(id: Int) async -> Bool {
        isProcessing = true; error = nil
        do {
            try await service.delete(id: id)
            items.removeAll { $0.id == id }
            isProcessing = false
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isProcessing = false
            return false
        }
    }
}