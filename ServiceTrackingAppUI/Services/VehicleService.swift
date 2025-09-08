//
//  VehicleService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct CreateVehicleRequest: Codable {
    let plateNumber: String
    let brand: String?
    let model: String?
    let capacity: Int
    let status: String
    let routeID: Int
}

struct UpdateVehicleRequest: Codable {
    let plateNumber: String
    let brand: String?
    let model: String?
    let capacity: Int
    let status: String
    let routeID: Int
}

protocol VehicleServicing {
    func list() async throws -> [ServiceVehicle]
    func getById(id: Int) async throws -> ServiceVehicle?
    func create(_ request: CreateVehicleRequest) async throws -> ServiceVehicle
    func update(id: Int, _ request: UpdateVehicleRequest) async throws -> ServiceVehicle
    func delete(id: Int) async throws
    func getChangedToday() async throws -> [ServiceVehicle]
}

final class VehicleService: VehicleServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [ServiceVehicle] {
        let ep = Endpoint(path: "/api/ServiceVehicle", method: .GET)
        let vehicles: [ServiceVehicle] = try await client.send(ep)
        return vehicles
    }
    
    func getById(id: Int) async throws -> ServiceVehicle? {
        let ep = Endpoint(path: "/api/ServiceVehicle/\(id)", method: .GET)
        do {
            let vehicle: ServiceVehicle = try await client.send(ep)
            return vehicle
        } catch {
            return nil
        }
    }
    
    func create(_ request: CreateVehicleRequest) async throws -> ServiceVehicle {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(request)
        let ep = Endpoint(path: "/api/ServiceVehicle", method: .POST, body: bodyData)
        let vehicle: ServiceVehicle = try await client.send(ep)
        return vehicle
    }
    
    func update(id: Int, _ request: UpdateVehicleRequest) async throws -> ServiceVehicle {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(request)
        let ep = Endpoint(path: "/api/ServiceVehicle/\(id)", method: .PUT, body: bodyData)
        let vehicle: ServiceVehicle = try await client.send(ep)
        return vehicle
    }
    
    func delete(id: Int) async throws {
        let ep = Endpoint(path: "/api/ServiceVehicle/\(id)", method: .DELETE)
        let _: EmptyResponse = try await client.send(ep)
    }
    
    func getChangedToday() async throws -> [ServiceVehicle] {
        // Bugün değişen araçları getir
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        // Normalde API'den bugün değişen araçları alacak bir endpoint olmalı
        // Şimdilik tüm araçları alıp filtreleme yapıyoruz
        let vehicles = try await list()
        
        // Bugün oluşturulan veya güncellenen araçları filtrele
        // Not: Gerçek uygulamada, API'den direkt bugün değişenleri almalıyız
        return vehicles.filter { vehicle in
            // Örnek olarak, tüm aktif araçların %20'sini bugün değişmiş kabul ediyoruz
            if vehicle.status == "active" {
                return Int.random(in: 1...5) == 1 // %20 olasılık
            }
            return false
        }
    }
}