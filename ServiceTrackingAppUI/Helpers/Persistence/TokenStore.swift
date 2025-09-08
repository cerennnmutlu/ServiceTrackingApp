//
//  TokenStore.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol TokenStore: AnyObject {      // ← burası önemli
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    func clear()
}

final class KeychainTokenStore: TokenStore {
    static let shared = KeychainTokenStore()
    private let accessTokenService = "ServiceTrackingAppUI.accessToken"
    private let refreshTokenService = "ServiceTrackingAppUI.refreshToken"
    private init() {}

    var accessToken: String? {
        get { Keychain.read(service: accessTokenService) }
        set {
            if let v = newValue { Keychain.save(service: accessTokenService, value: v) }
            else { Keychain.delete(service: accessTokenService) }
        }
    }
    
    var refreshToken: String? {
        get { Keychain.read(service: refreshTokenService) }
        set {
            if let v = newValue { Keychain.save(service: refreshTokenService, value: v) }
            else { Keychain.delete(service: refreshTokenService) }
        }
    }
    func clear() {
        Keychain.delete(service: accessTokenService)
        Keychain.delete(service: refreshTokenService)
    }
}
