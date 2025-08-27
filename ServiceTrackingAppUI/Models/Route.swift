//
//  Route.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct RouteModel: Decodable, Identifiable {
    let id: Int
    let routeName: String
    let description: String?
    let distance: Double?
    let estimatedDuration: Int?
    let status: String?
    let createdAt: Date?
    let updatedAt: Date?

    // Opsiyonel: include ile gelirse
    let serviceVehicles: [ServiceVehicle]?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id                = try c.decodeFlexible(Int.self,    keys: ["routeID","RouteID","id","Id"])
        routeName         = try c.decodeFlexible(String.self, keys: ["routeName","RouteName"])
        description       = c.decodeFlexibleIfPresent(String.self, keys: ["description","Description"])
        distance          = c.decodeFlexibleIfPresent(Double.self, keys: ["distance","Distance"])
        estimatedDuration = c.decodeFlexibleIfPresent(Int.self,    keys: ["estimatedDuration","EstimatedDuration"])
        status            = c.decodeFlexibleIfPresent(String.self, keys: ["status","Status"])
        createdAt         = c.decodeFlexibleIfPresent(Date.self,   keys: ["createdAt","CreatedAt"])
        updatedAt         = c.decodeFlexibleIfPresent(Date.self,   keys: ["updatedAt","UpdatedAt"])
        serviceVehicles   = c.decodeFlexibleIfPresent([ServiceVehicle].self, keys: ["serviceVehicles","ServiceVehicles"])
    }
}
