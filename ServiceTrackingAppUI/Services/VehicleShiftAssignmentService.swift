//
//  VehicleShiftAssignmentService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

// MARK: - Request Models
struct CreateVehicleShiftAssignmentRequest: Codable {
    let serviceVehicleID: Int
    let shiftID: Int
    let assignmentDate: String
    
    enum CodingKeys: String, CodingKey {
        case serviceVehicleID = "ServiceVehicleID"
        case shiftID = "ShiftID"
        case assignmentDate = "AssignmentDate"
    }
}

struct UpdateVehicleShiftAssignmentRequest: Codable {
    let serviceVehicleID: Int
    let shiftID: Int
    let assignmentDate: String
    
    enum CodingKeys: String, CodingKey {
        case serviceVehicleID = "ServiceVehicleID"
        case shiftID = "ShiftID"
        case assignmentDate = "AssignmentDate"
    }
}

struct CreateBulkAssignmentsRequest: Codable {
    let assignments: [CreateVehicleShiftAssignmentRequest]
    
    enum CodingKeys: String, CodingKey {
        case assignments = "Assignments"
    }
}

struct VehicleShiftAssignmentUpdateResponse: Codable {
    let message: String
    let error: String?
}

struct BulkAssignmentResponse: Codable {
    let message: String
    let createdCount: Int
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case createdCount = "CreatedCount"
        case error = "Error"
    }
}

protocol VehicleShiftAssignmentServicing {
    func list() async throws -> [VehicleShiftAssignment]
    func getById(id: Int) async throws -> VehicleShiftAssignment
    func getByVehicle(vehicleId: Int) async throws -> [VehicleShiftAssignment]
    func getByShift(shiftId: Int) async throws -> [VehicleShiftAssignment]
    func getByDate(date: String) async throws -> [VehicleShiftAssignment]
    func getTodayAssignments() async throws -> [VehicleShiftAssignment]
    func create(_ assignment: CreateVehicleShiftAssignmentRequest) async throws -> VehicleShiftAssignment
    func createBulkAssignments(_ request: CreateBulkAssignmentsRequest) async throws -> BulkAssignmentResponse
    func update(id: Int, _ assignment: UpdateVehicleShiftAssignmentRequest) async throws -> VehicleShiftAssignmentUpdateResponse
    func delete(id: Int) async throws
}

final class VehicleShiftAssignmentService: VehicleShiftAssignmentServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [VehicleShiftAssignment] {
        let ep = Endpoint(path: "/api/VehicleShiftAssignment", method: .GET)
        let assignments: [VehicleShiftAssignment] = try await client.send(ep)
        return assignments
    }
    
    func getById(id: Int) async throws -> VehicleShiftAssignment {
        let ep = Endpoint(path: "/api/VehicleShiftAssignment/\(id)", method: .GET)
        let assignment: VehicleShiftAssignment = try await client.send(ep)
        return assignment
    }
    
    func getByVehicle(vehicleId: Int) async throws -> [VehicleShiftAssignment] {
        let ep = Endpoint(path: "/api/VehicleShiftAssignment/vehicle/\(vehicleId)", method: .GET)
        let assignments: [VehicleShiftAssignment] = try await client.send(ep)
        return assignments
    }
    
    func getByShift(shiftId: Int) async throws -> [VehicleShiftAssignment] {
        let ep = Endpoint(path: "/api/VehicleShiftAssignment/shift/\(shiftId)", method: .GET)
        let assignments: [VehicleShiftAssignment] = try await client.send(ep)
        return assignments
    }
    
    func getByDate(date: String) async throws -> [VehicleShiftAssignment] {
        let ep = Endpoint(path: "/api/VehicleShiftAssignment/date/\(date)", method: .GET)
        let assignments: [VehicleShiftAssignment] = try await client.send(ep)
        return assignments
    }
    
    func getTodayAssignments() async throws -> [VehicleShiftAssignment] {
        let ep = Endpoint(path: "/api/VehicleShiftAssignment/today", method: .GET)
        let assignments: [VehicleShiftAssignment] = try await client.send(ep)
        return assignments
    }
    
    func create(_ assignment: CreateVehicleShiftAssignmentRequest) async throws -> VehicleShiftAssignment {
        let bodyData = try JSONEncoder().encode(assignment)
        let ep = Endpoint(path: "/api/VehicleShiftAssignment", method: .POST, body: bodyData)
        let createdAssignment: VehicleShiftAssignment = try await client.send(ep)
        return createdAssignment
    }
    
    func createBulkAssignments(_ request: CreateBulkAssignmentsRequest) async throws -> BulkAssignmentResponse {
        let bodyData = try JSONEncoder().encode(request)
        let ep = Endpoint(path: "/api/VehicleShiftAssignment/bulk", method: .POST, body: bodyData)
        let response: BulkAssignmentResponse = try await client.send(ep)
        return response
    }
    
    func update(id: Int, _ assignment: UpdateVehicleShiftAssignmentRequest) async throws -> VehicleShiftAssignmentUpdateResponse {
        let bodyData = try JSONEncoder().encode(assignment)
        let ep = Endpoint(path: "/api/VehicleShiftAssignment/\(id)", method: .PUT, body: bodyData)
        let response: VehicleShiftAssignmentUpdateResponse = try await client.send(ep)
        return response
    }
    
    func delete(id: Int) async throws {
        let ep = Endpoint(path: "/api/VehicleShiftAssignment/\(id)", method: .DELETE)
        let _: EmptyResponse = try await client.send(ep)
    }
}