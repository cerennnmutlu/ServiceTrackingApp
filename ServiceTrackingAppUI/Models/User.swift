//
//  User.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let fullName: String
    let username: String
    let email: String
    let roleID: Int?
    let createdAt: Date?
    let updatedAt: Date?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id        = try c.decodeFlexible(Int.self,    keys: ["userID","UserID","id","Id"])
        fullName  = try c.decodeFlexible(String.self, keys: ["fullName","FullName","name","Name"])
        username  = try c.decodeFlexible(String.self, keys: ["username","Username"])
        email     = try c.decodeFlexible(String.self, keys: ["email","Email"])
        roleID    = c.decodeFlexibleIfPresent(Int.self, keys: ["roleID","RoleID"])
        createdAt = c.decodeFlexibleIfPresent(Date.self, keys: ["createdAt","CreatedAt"])
        updatedAt = c.decodeFlexibleIfPresent(Date.self, keys: ["updatedAt","UpdatedAt"])
    }
}
