//
//  Shift.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct Shift: Decodable, Identifiable {
    let id: Int
    let shiftName: String
    /// Backend `TimeSpan` →  "HH:mm:ss" stringi olarak tutuluyor.
    let startTime: String
    let endTime: String
    let status: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    var isActive: Bool {
        return status == "active"
    }
    
    // Normal initializer for testing and previews
    init(id: Int, shiftName: String, startTime: String, endTime: String, status: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.shiftName = shiftName
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id        = try c.decodeFlexible(Int.self,    keys: ["shiftID","ShiftID","id","Id"])
        shiftName = try c.decodeFlexible(String.self, keys: ["shiftName","ShiftName"])
        startTime = try c.decodeFlexible(String.self, keys: ["startTime","StartTime"])
        endTime   = try c.decodeFlexible(String.self, keys: ["endTime","EndTime"])
        status    = c.decodeFlexibleIfPresent(String.self, keys: ["status","Status"])
        createdAt = c.decodeFlexibleIfPresent(Date.self,   keys: ["createdAt","CreatedAt"])
        updatedAt = c.decodeFlexibleIfPresent(Date.self,   keys: ["updatedAt","UpdatedAt"])
    }
}
