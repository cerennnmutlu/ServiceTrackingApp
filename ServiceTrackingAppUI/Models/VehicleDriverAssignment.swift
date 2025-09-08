//
//  VehicleDriverAssignment.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct VehicleDriverAssignment: Decodable, Identifiable {
    let id: Int
    let serviceVehicleID: Int
    let driverID: Int
    let startDate: Date
    let endDate: Date?
    let createdAt: Date?

    let serviceVehicle: ServiceVehicle?
    let driver: Driver?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id               = try c.decodeFlexible(Int.self, keys: ["assignmentID","AssignmentID","id","Id"])
        serviceVehicleID = try c.decodeFlexible(Int.self, keys: ["serviceVehicleID","ServiceVehicleID"])
        driverID         = try c.decodeFlexible(Int.self, keys: ["driverID","DriverID"])
        
        // Date decoding with multiple strategies
        startDate = try c.decodeFlexibleDate(keys: ["startDate","StartDate"])
        endDate = c.decodeFlexibleDateIfPresent(keys: ["endDate","EndDate"])
        createdAt = c.decodeFlexibleDateIfPresent(keys: ["createdAt","CreatedAt"])
        
        serviceVehicle   = c.decodeFlexibleIfPresent(ServiceVehicle.self, keys: ["serviceVehicle","ServiceVehicle"])
        driver           = c.decodeFlexibleIfPresent(Driver.self, keys: ["driver","Driver"])
    }
}
