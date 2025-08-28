//
//  Keychain.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//


import Foundation
import Security //Keychain Services C API’si

enum Keychain {
    static func save(service: String, value: String) {
        let data = Data(value.utf8)
        delete(service: service)// aynı service için "önce sil" stratejisi
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword, // "şifre benzeri gizli veri" sınıfı
            kSecAttrService as String: service,            // eşsiz anahtar gibi davranıyor
            kSecValueData as String: data                  // saklanacak veri (şifre/token)
        ]
        SecItemAdd(q as CFDictionary, nil)
    }

    //service ile eşleşen ilk girdinin Data’sını döndürür,
    static func read(service: String) -> String? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }

    static func delete(service: String) {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(q as CFDictionary)
    }
}
