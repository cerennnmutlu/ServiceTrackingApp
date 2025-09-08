//
//  VehicleDriverAssignmentService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

// MARK: - Request Models
struct CreateVehicleDriverAssignmentRequest: Codable {
    let serviceVehicleID: Int
    let driverID: Int
    let startDate: Date
    let endDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case serviceVehicleID = "ServiceVehicleID"
        case driverID = "DriverID"
        case startDate = "StartDate"
        case endDate = "EndDate"
    }
}

struct UpdateVehicleDriverAssignmentRequest: Codable {
    let serviceVehicleID: Int
    let driverID: Int
    let startDate: Date
    let endDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case serviceVehicleID = "ServiceVehicleID"
        case driverID = "DriverID"
        case startDate = "StartDate"
        case endDate = "EndDate"
    }
}

struct VehicleDriverAssignmentUpdateResponse: Codable {
    let message: String
    let error: String?
}

protocol VehicleDriverAssignmentServicing {
    func list() async throws -> [VehicleDriverAssignment]
    func getById(id: Int) async throws -> VehicleDriverAssignment
    func getByVehicle(vehicleId: Int) async throws -> [VehicleDriverAssignment]
    func getByDriver(driverId: Int) async throws -> [VehicleDriverAssignment]
    func create(_ assignment: CreateVehicleDriverAssignmentRequest) async throws -> VehicleDriverAssignment
    func update(id: Int, _ assignment: UpdateVehicleDriverAssignmentRequest) async throws -> VehicleDriverAssignmentUpdateResponse
    func delete(id: Int) async throws
}

final class VehicleDriverAssignmentService: VehicleDriverAssignmentServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [VehicleDriverAssignment] {
        let ep = Endpoint(path: "/api/VehicleDriverAssignment", method: .GET)
        let assignments: [VehicleDriverAssignment] = try await client.send(ep)
        return assignments
    }
    
    func getById(id: Int) async throws -> VehicleDriverAssignment {
        let ep = Endpoint(path: "/api/VehicleDriverAssignment/\(id)", method: .GET)
        let assignment: VehicleDriverAssignment = try await client.send(ep)
        return assignment
    }
    
    func getByVehicle(vehicleId: Int) async throws -> [VehicleDriverAssignment] {
        let ep = Endpoint(path: "/api/VehicleDriverAssignment/vehicle/\(vehicleId)", method: .GET)
        let assignments: [VehicleDriverAssignment] = try await client.send(ep)
        return assignments
    }
    
    func getByDriver(driverId: Int) async throws -> [VehicleDriverAssignment] {
        let ep = Endpoint(path: "/api/VehicleDriverAssignment/driver/\(driverId)", method: .GET)
        let assignments: [VehicleDriverAssignment] = try await client.send(ep)
        return assignments
    }
    
    func create(_ assignment: CreateVehicleDriverAssignmentRequest) async throws -> VehicleDriverAssignment {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(assignment)
        let ep = Endpoint(path: "/api/VehicleDriverAssignment", method: .POST, body: bodyData)
        let createdAssignment: VehicleDriverAssignment = try await client.send(ep)
        return createdAssignment
    }
    
    func update(id: Int, _ assignment: UpdateVehicleDriverAssignmentRequest) async throws -> VehicleDriverAssignmentUpdateResponse {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(assignment)
        let ep = Endpoint(path: "/api/VehicleDriverAssignment/\(id)", method: .PUT, body: bodyData)
        let response: VehicleDriverAssignmentUpdateResponse = try await client.send(ep)
        return response
    }
    
    func delete(id: Int) async throws {
        let ep = Endpoint(path: "/api/VehicleDriverAssignment/\(id)", method: .DELETE)
        let _: EmptyResponse = try await client.send(ep)
    }
}