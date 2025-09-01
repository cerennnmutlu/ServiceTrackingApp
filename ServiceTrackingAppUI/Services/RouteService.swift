//
//  RouteService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol RouteServicing {
    func list() async throws -> [RouteModel]
    func create(_ route: CreateRouteRequest) async throws -> RouteModel
    func update(id: Int, _ route: UpdateRouteRequest) async throws -> RouteModel
    func delete(id: Int) async throws
}

final class RouteService: RouteServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [RouteModel] {
        let ep = Endpoint(path: "/api/Route", method: .GET)
        let routes: [RouteModel] = try await client.send(ep)
        return routes
    }
    
    func create(_ route: CreateRouteRequest) async throws -> RouteModel {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(route)
        let ep = Endpoint(path: "/api/Route", method: .POST, body: bodyData)
        let createdRoute: RouteModel = try await client.send(ep)
        return createdRoute
    }
    
    func update(id: Int, _ route: UpdateRouteRequest) async throws -> RouteModel {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(route)
        let ep = Endpoint(path: "/api/Route/\(id)", method: .PUT, body: bodyData)
        let updatedRoute: RouteModel = try await client.send(ep)
        return updatedRoute
    }
    
    func delete(id: Int) async throws {
        let ep = Endpoint(path: "/api/Route/\(id)", method: .DELETE)
        let _: EmptyResponse = try await client.send(ep)
    }
}

// MARK: - Request Models
struct CreateRouteRequest: Codable {
    let routeName: String
    let description: String?
    let distance: Double?
    let estimatedDuration: Int?
    let status: String?
}

struct UpdateRouteRequest: Codable {
    let routeName: String
    let description: String?
    let distance: Double?
    let estimatedDuration: Int?
    let status: String?
}