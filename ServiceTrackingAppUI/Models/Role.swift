//
//  Role.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

struct Role: Decodable, Identifiable {
    let id: Int
    let roleName: String
    let users: [User]?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id       = try c.decodeFlexible(Int.self,    keys: ["roleID","RoleID","id","Id"])
        roleName = try c.decodeFlexible(String.self, keys: ["roleName","RoleName","name","Name"])
        users    = c.decodeFlexibleIfPresent([User].self, keys: ["users","Users"])
    }
}
