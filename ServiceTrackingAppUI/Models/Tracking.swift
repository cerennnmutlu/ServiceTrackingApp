//
//  Tracking.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct Tracking: Decodable, Identifiable {
    let id: Int
    let serviceVehicleID: Int
    let shiftID: Int
    /// Backend `DateTimeOffset` → ISO-8601 gelir; `Date` olarak çözüyoruz.
    let trackingDateTime: Date
    let movementType: String
    let createdAt: Date?

    let serviceVehicle: ServiceVehicle?
    let shift: Shift?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id               = try c.decodeFlexible(Int.self, keys: ["trackingID","TrackingID","id","Id"])
        serviceVehicleID = try c.decodeFlexible(Int.self, keys: ["serviceVehicleID","ServiceVehicleID"])
        shiftID          = try c.decodeFlexible(Int.self, keys: ["shiftID","ShiftID"])
        trackingDateTime = try c.decodeFlexible(Date.self, keys: ["trackingDateTime","TrackingDateTime"])
        movementType     = try c.decodeFlexible(String.self, keys: ["movementType","MovementType"])
        createdAt        = c.decodeFlexibleIfPresent(Date.self, keys: ["createdAt","CreatedAt"])
        serviceVehicle   = c.decodeFlexibleIfPresent(ServiceVehicle.self, keys: ["serviceVehicle","ServiceVehicle"])
        shift            = c.decodeFlexibleIfPresent(Shift.self, keys: ["shift","Shift"])
    }
}
