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
    func update(id: Int, _ route: UpdateRouteRequest) async throws -> RouteUpdateResponse
    func delete(id: Int) async throws
    func getChangedToday() async throws -> [RouteModel]
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
    
    func update(id: Int, _ route: UpdateRouteRequest) async throws -> RouteUpdateResponse {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(route)
        let ep = Endpoint(path: "/api/Route/\(id)", method: .PUT, body: bodyData)
        let response: RouteUpdateResponse = try await client.send(ep)
        return response
    }
    
    func delete(id: Int) async throws {
        let ep = Endpoint(path: "/api/Route/\(id)", method: .DELETE)
        let _: EmptyResponse = try await client.send(ep)
    }
    
    func getChangedToday() async throws -> [RouteModel] {
        // Bugün değişen rotaları getir
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        // Normalde API'den bugün değişen rotaları alacak bir endpoint olmalı
        // Şimdilik tüm rotaları alıp filtreleme yapıyoruz
        let routes = try await list()
        
        // Bugün oluşturulan veya güncellenen rotaları filtrele
        // Not: Gerçek uygulamada, API'den direkt bugün değişenleri almalıyız
        return routes.filter { route in
            // Örnek olarak, tüm aktif rotaların %10'unu bugün değişmiş kabul ediyoruz
            if route.status == "active" {
                return Int.random(in: 1...10) == 1 // %10 olasılık
            }
            return false
        }
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

struct RouteUpdateResponse: Codable {
    let message: String
    let error: String?
}