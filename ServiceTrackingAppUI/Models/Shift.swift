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
    /// Backend `TimeSpan` → genellikle "HH:mm:ss" string gelir; string tutuyoruz.
    let startTime: String
    let endTime: String
    let status: String?
    let createdAt: Date?
    let updatedAt: Date?

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
