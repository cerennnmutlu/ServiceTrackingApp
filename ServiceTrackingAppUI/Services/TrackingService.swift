//
//  TrackingService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

// MARK: - Request Models
struct CreateTrackingRequest: Codable {
    let serviceVehicleID: Int
    let shiftID: Int
    let trackingDateTime: Date
    let movementType: String
    
    enum CodingKeys: String, CodingKey {
        case serviceVehicleID = "ServiceVehicleID"
        case shiftID = "ShiftID"
        case trackingDateTime = "TrackingDateTime"
        case movementType = "MovementType"
    }
}

struct UpdateTrackingRequest: Codable {
    let serviceVehicleID: Int
    let shiftID: Int
    let trackingDateTime: Date
    let movementType: String
    
    enum CodingKeys: String, CodingKey {
        case serviceVehicleID = "ServiceVehicleID"
        case shiftID = "ShiftID"
        case trackingDateTime = "TrackingDateTime"
        case movementType = "MovementType"
    }
}

struct TrackingUpdateResponse: Codable {
    let message: String
    let error: String?
}

protocol TrackingServicing {
    func list() async throws -> [Tracking]
    func getById(id: Int) async throws -> Tracking
    func getByVehicle(vehicleId: Int) async throws -> [Tracking]
    func getByDate(date: String) async throws -> [Tracking]
    func create(_ tracking: CreateTrackingRequest) async throws -> Tracking
    func update(id: Int, _ tracking: UpdateTrackingRequest) async throws -> TrackingUpdateResponse
    func delete(id: Int) async throws
}

final class TrackingService: TrackingServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [Tracking] {
        let ep = Endpoint(path: "/api/Tracking", method: .GET)
        let trackings: [Tracking] = try await client.send(ep)
        return trackings
    }
    
    func getById(id: Int) async throws -> Tracking {
        let ep = Endpoint(path: "/api/Tracking/\(id)", method: .GET)
        let tracking: Tracking = try await client.send(ep)
        return tracking
    }
    
    func getByVehicle(vehicleId: Int) async throws -> [Tracking] {
        let ep = Endpoint(path: "/api/Tracking/vehicle/\(vehicleId)", method: .GET)
        let trackings: [Tracking] = try await client.send(ep)
        return trackings
    }
    
    func getByDate(date: String) async throws -> [Tracking] {
        let ep = Endpoint(path: "/api/Tracking/date/\(date)", method: .GET)
        let trackings: [Tracking] = try await client.send(ep)
        return trackings
    }
    
    func create(_ tracking: CreateTrackingRequest) async throws -> Tracking {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(tracking)
        let ep = Endpoint(path: "/api/Tracking", method: .POST, body: bodyData)
        let createdTracking: Tracking = try await client.send(ep)
        return createdTracking
    }
    
    func update(id: Int, _ tracking: UpdateTrackingRequest) async throws -> TrackingUpdateResponse {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(tracking)
        let ep = Endpoint(path: "/api/Tracking/\(id)", method: .PUT, body: bodyData)
        let response: TrackingUpdateResponse = try await client.send(ep)
        return response
    }
    
    func delete(id: Int) async throws {
        let ep = Endpoint(path: "/api/Tracking/\(id)", method: .DELETE)
        let _: EmptyResponse = try await client.send(ep)
    }
}