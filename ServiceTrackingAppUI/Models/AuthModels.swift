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

//dışarıdan gelen json nesnesi çözülebilir
struct UserInfo: Decodable {
    let userID: Int
    let fullName: String
    let username: String
    let email: String
    let roleID: Int?

    //çözücü
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        userID   = try c.decodeFlexible(Int.self,    keys: ["userID","UserID","id","Id"])
        fullName = try c.decodeFlexible(String.self, keys: ["fullName","FullName","name","Name"])
        username = try c.decodeFlexible(String.self, keys: ["username","Username"])
        email    = try c.decodeFlexible(String.self, keys: ["email","Email"])
        roleID = try? c.decodeFlexible(Int.self, keys: ["roleID","RoleID"])
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


// MARK: - Register DTOs
struct RegisterRequest: Encodable {
    let fullName: String
    let username: String
    let email: String
    let password: String
    let roleID: Int

    enum CodingKeys: String, CodingKey {
        case fullName, username, email, password
        case roleID = "RoleID"  // Backend expects "RoleID" not "roleID"
    }
}

struct RegisterResponse: Decodable {
    let message: String?
    let user: UserInfo?
}

// MARK: - Update Profile DTOs
struct UpdateProfileRequest: Encodable {
    let fullName: String
    let username: String
    let email: String
}

struct UpdateProfileResponse: Decodable {
    let message: String?
    let user: User?
}

// MARK: - Change Password DTOs
struct ChangePasswordRequest: Encodable {
    let currentPassword: String
    let newPassword: String
}

struct ChangePasswordResponse: Decodable {
    let message: String?
    let success: Bool?
}
