//
//  ShiftService.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol ShiftServicing {
    func list() async throws -> [Shift]
}

final class ShiftService: ShiftServicing {
    private let client: APIClient
    init(client: APIClient = APIClient()) { self.client = client }

    func list() async throws -> [Shift] {
        let ep = Endpoint(path: "/api/Shift", method: .GET)
        let shifts: [Shift] = try await client.send(ep)
        return shifts
    }
}