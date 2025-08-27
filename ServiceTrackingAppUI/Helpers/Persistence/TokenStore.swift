//
//  TokenStore.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

protocol TokenStore: AnyObject {      // ← burası önemli
    var token: String? { get set }
    func clear()
}

final class KeychainTokenStore: TokenStore {
    static let shared = KeychainTokenStore()
    private let service = "ServiceTrackingAppUI.token"
    private init() {}

    var token: String? {
        get { Keychain.read(service: service) }
        set {
            if let v = newValue { Keychain.save(service: service, value: v) }
            else { Keychain.delete(service: service) }
        }
    }
    func clear() { Keychain.delete(service: service) }
}
