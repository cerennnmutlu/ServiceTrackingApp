//
//  VehicleService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol VehicleServicing {
    func list() async throws -> [ServiceVehicle]
}

final class VehicleService: VehicleServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [ServiceVehicle] {
        let ep = Endpoint(path: "/api/ServiceVehicle", method: .GET)
        let vehicles: [ServiceVehicle] = try await client.send(ep)
        return vehicles
    }
}