//
//  RouteService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol RouteServicing {
    func list() async throws -> [RouteModel]
}

final class RouteService: RouteServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [RouteModel] {
        let ep = Endpoint(path: "/api/Route", method: .GET)
        let routes: [RouteModel] = try await client.send(ep)
        return routes
    }
}