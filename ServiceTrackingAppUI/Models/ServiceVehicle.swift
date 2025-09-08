//
//  ServiceVehicle.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct ServiceVehicle: Decodable, Identifiable {
    let id: Int
    let plateNumber: String
    let brand: String?
    let model: String?
    let capacity: Int
    let status: String?
    let routeID: Int
    let createdAt: Date?
    let updatedAt: Date?
    
    var isActive: Bool {
        return status == "active"
    }

    let route: RouteModel?
    let vehicleDriverAssignments: [VehicleDriverAssignment]?
    let vehicleShiftAssignments: [VehicleShiftAssignment]?
    let trackings: [Tracking]?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id       = try c.decodeFlexible(Int.self,    keys: ["serviceVehicleID","ServiceVehicleID","id","Id"])
        plateNumber = try c.decodeFlexible(String.self, keys: ["plateNumber","PlateNumber"])
        brand    = c.decodeFlexibleIfPresent(String.self, keys: ["brand","Brand"])
        model    = c.decodeFlexibleIfPresent(String.self, keys: ["model","Model"])
        capacity = try c.decodeFlexible(Int.self, keys: ["capacity","Capacity"])
        status   = c.decodeFlexibleIfPresent(String.self, keys: ["status","Status"])
        routeID  = try c.decodeFlexible(Int.self, keys: ["routeID","RouteID"])
        createdAt = c.decodeFlexibleIfPresent(Date.self, keys: ["createdAt","CreatedAt"])
        updatedAt = c.decodeFlexibleIfPresent(Date.self, keys: ["updatedAt","UpdatedAt"])

        route      = c.decodeFlexibleIfPresent(RouteModel.self, keys: ["route","Route"])
        vehicleDriverAssignments = c.decodeFlexibleIfPresent([VehicleDriverAssignment].self, keys: ["vehicleDriverAssignments","VehicleDriverAssignments"])
        vehicleShiftAssignments  = c.decodeFlexibleIfPresent([VehicleShiftAssignment].self,  keys: ["vehicleShiftAssignments","VehicleShiftAssignments"])
        trackings = c.decodeFlexibleIfPresent([Tracking].self, keys: ["trackings","Trackings"])
    }
}
