//
//  DriverService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol DriverServicing {
    func list() async throws -> [Driver]
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
}
