//
//  VehicleShiftAssignment.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct VehicleShiftAssignment: Decodable, Identifiable {
    let id: Int
    let serviceVehicleID: Int
    let shiftID: Int
    /// Backend date  alanı sadece "YYYY-MM-DD" ; string olarak saklıyoruz.
    let assignmentDate: String
    let createdAt: Date?

    let serviceVehicle: ServiceVehicle?
    let shift: Shift?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id               = try c.decodeFlexible(Int.self, keys: ["assignmentID","AssignmentID","id","Id"])
        serviceVehicleID = try c.decodeFlexible(Int.self, keys: ["serviceVehicleID","ServiceVehicleID"])
        shiftID          = try c.decodeFlexible(Int.self, keys: ["shiftID","ShiftID"])
        assignmentDate   = try c.decodeFlexible(String.self, keys: ["assignmentDate","AssignmentDate"])
        createdAt        = c.decodeFlexibleIfPresent(Date.self, keys: ["createdAt","CreatedAt"])
        serviceVehicle   = c.decodeFlexibleIfPresent(ServiceVehicle.self, keys: ["serviceVehicle","ServiceVehicle"])
        shift            = c.decodeFlexibleIfPresent(Shift.self, keys: ["shift","Shift"])
    }
}
