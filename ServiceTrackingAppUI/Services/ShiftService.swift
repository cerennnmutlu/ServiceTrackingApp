//
//  ShiftService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol ShiftServicing {
    func list() async throws -> [Shift]
    func create(_ shift: CreateShiftRequest) async throws -> Shift
    func update(id: Int, _ shift: UpdateShiftRequest) async throws -> Shift
    func delete(id: Int) async throws
}

final class ShiftService: ShiftServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [Shift] {
        let ep = Endpoint(path: "/api/Shift", method: .GET)
        let shifts: [Shift] = try await client.send(ep)
        return shifts
    }
    
    func create(_ shift: CreateShiftRequest) async throws -> Shift {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(shift)
        let ep = Endpoint(path: "/api/Shift", method: .POST, body: bodyData)
        let createdShift: Shift = try await client.send(ep)
        return createdShift
    }
    
    func update(id: Int, _ shift: UpdateShiftRequest) async throws -> Shift {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(shift)
        let ep = Endpoint(path: "/api/Shift/\(id)", method: .PUT, body: bodyData)
        let updatedShift: Shift = try await client.send(ep)
        return updatedShift
    }
    
    func delete(id: Int) async throws {
        let ep = Endpoint(path: "/api/Shift/\(id)", method: .DELETE)
        let _: EmptyResponse = try await client.send(ep)
    }
}

// MARK: - Request Models
struct CreateShiftRequest: Codable {
    let shiftName: String
    let startTime: String
    let endTime: String
    let status: String?
}

struct UpdateShiftRequest: Codable {
    let shiftName: String
    let startTime: String
    let endTime: String
    let status: String?
}