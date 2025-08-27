//
//  AuthModels.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//
import Foundation

struct LoginRequest: Encodable {
    /// API Username veya Email alıyor; biz hepsini `username` alanına koyuyoruz.
    let username: String
    let password: String
}

struct UserInfo: Decodable {
    let userID: Int
    let fullName: String
    let username: String
    let email: String
    let roleName: String

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        userID   = try c.decodeFlexible(Int.self,    keys: ["userID","UserID","id","Id"])
        fullName = try c.decodeFlexible(String.self, keys: ["fullName","FullName","name","Name"])
        username = try c.decodeFlexible(String.self, keys: ["username","Username"])
        email    = try c.decodeFlexible(String.self, keys: ["email","Email"])
        roleName = (try? c.decodeFlexible(String.self, keys: ["roleName","RoleName","role","Role"])) ?? ""
    }
}

struct LoginResponse: Decodable {
    let token: String
    let user: UserInfo
    let expiresAt: Date?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        token     = try c.decodeFlexible(String.self, keys: ["token","accessToken","jwt","jwtToken"])
        user      = try c.decodeFlexible(UserInfo.self, keys: ["user","User"])
        expiresAt = c.decodeFlexibleIfPresent(Date.self, keys: ["expiresAt","ExpiresAt","expiresAtUtc"])
    }
}
