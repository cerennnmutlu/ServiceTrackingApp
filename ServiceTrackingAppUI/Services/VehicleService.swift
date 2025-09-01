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
    func create(_ request: CreateVehicleRequest) async throws -> ServiceVehicle
    func update(id: Int, _ request: UpdateVehicleRequest) async throws -> ServiceVehicle
    func delete(id: Int) async throws
}

final class VehicleService: VehicleServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [ServiceVehicle] {
        let ep = Endpoint(path: "/api/ServiceVehicle", method: .GET)
        let vehicles: [ServiceVehicle] = try await client.send(ep)
        return vehicles
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
}