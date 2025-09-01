//
//  DriverService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol DriverServicing {
    func list() async throws -> [Driver]
    func create(_ driver: CreateDriverRequest) async throws -> Driver
    func update(id: Int, _ driver: UpdateDriverRequest) async throws -> DriverUpdateResponse
    func delete(id: Int) async throws
}

final class DriverService: DriverServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [Driver] {
        // Eğer API `{"data":[...drivers...]}` dönerse:
        // let wrapper: ApiList<Driver> = try await client.send(Endpoint(path: "/api/Driver", method: .GET))
        // return wrapper.data
        let ep = Endpoint(path: "/api/Driver", method: .GET)
        let drivers: [Driver] = try await client.send(ep)
        return drivers
    }
    
    func create(_ driver: CreateDriverRequest) async throws -> Driver {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(driver)
        let ep = Endpoint(path: "/api/Driver", method: .POST, body: bodyData)
        let createdDriver: Driver = try await client.send(ep)
        return createdDriver
    }
    
    func update(id: Int, _ driver: UpdateDriverRequest) async throws -> DriverUpdateResponse {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(driver)
        let ep = Endpoint(path: "/api/Driver/\(id)", method: .PUT, body: bodyData)
        let response: DriverUpdateResponse = try await client.send(ep)
        return response
    }
    
    func delete(id: Int) async throws {
        let ep = Endpoint(path: "/api/Driver/\(id)", method: .DELETE)
        let _: EmptyResponse = try await client.send(ep)
    }
}

// MARK: - Request Models
struct CreateDriverRequest: Codable {
    let fullName: String
    let phone: String?
    let status: String?
}

struct UpdateDriverRequest: Codable {
    let fullName: String
    let phone: String?
    let status: String?
}

struct DriverUpdateResponse: Codable {
    let message: String
    let error: String?
}
