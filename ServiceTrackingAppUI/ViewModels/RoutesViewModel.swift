//
//  RoutesViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

@MainActor
final class RoutesViewModel: ObservableObject {
    @Published var items: [RouteModel] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var isProcessing = false

    private let service: RouteServicing
    init(service: RouteServicing) { self.service = service }

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
    
    func create(_ request: CreateRouteRequest) async -> Bool {
        isProcessing = true; error = nil
        do {
            let newRoute = try await service.create(request)
            items.append(newRoute)
            isProcessing = false
            return true
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isProcessing = false
            return false
        }
    }
    
    func update(id: Int, _ request: UpdateRouteRequest) async -> Bool {
        isProcessing = true; error = nil
        do {
            let response = try await service.update(id: id, request)
            // API'den sadece mesaj döndüğü için listeyi yeniden yükle
            await load()
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
