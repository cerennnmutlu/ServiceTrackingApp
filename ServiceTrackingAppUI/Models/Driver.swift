//
//  Driver.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct Driver: Decodable, Identifiable {
    let id: Int
    let fullName: String
    let phone: String?
    let status: String?
    let createdAt: Date?
    let updatedAt: Date?

    // Opsiyonel: API include ile gönderirse dolabilir
    let vehicleDriverAssignments: [VehicleDriverAssignment]?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id        = try c.decodeFlexible(Int.self,    keys: ["driverID","DriverID","id","Id"])
        fullName  = try c.decodeFlexible(String.self, keys: ["fullName","FullName","name","Name"])
        phone     = c.decodeFlexibleIfPresent(String.self, keys: ["phone","Phone"])
        status    = c.decodeFlexibleIfPresent(String.self, keys: ["status","Status"])
        createdAt = c.decodeFlexibleIfPresent(Date.self,   keys: ["createdAt","CreatedAt"])
        updatedAt = c.decodeFlexibleIfPresent(Date.self,   keys: ["updatedAt","UpdatedAt"])
        vehicleDriverAssignments = c.decodeFlexibleIfPresent([VehicleDriverAssignment].self,
                                                             keys: ["vehicleDriverAssignments","VehicleDriverAssignments"])
    }
}
