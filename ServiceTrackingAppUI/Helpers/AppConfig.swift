//
//  AppConfig.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

enum AppConfig {
    /// Info.plist → API_BASE_URL ( http://localhost:5059)
    static let baseURL: URL = {
        guard
            let s = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
            let url = URL(string: s),
            let scheme = url.scheme?.lowercased(),
            ["http","https"].contains(scheme)
        else {
            fatalError("API_BASE_URL eksik veya hatalı. Info.plist’i kontrol et.")
        }
        return url
    }()

    /// "api/Auth/login" → tam URL
    static func url(_ path: String, query: [URLQueryItem] = []) -> URL {
        let clean = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        var comps = URLComponents(url: baseURL.appendingPathComponent(clean), resolvingAgainstBaseURL: false)!
        comps.queryItems = query.isEmpty ? nil : query
        return comps.url!
    }
}
