//
//  APIClient.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

final class APIClient {
    private let baseURL: URL
    private let tokenStore: TokenStore
    private let urlSession: URLSession

    init(baseURL: URL = AppConfig.baseURL,
         tokenStore: TokenStore = KeychainTokenStore.shared,
         urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.tokenStore = tokenStore
        self.urlSession = urlSession
    }

    func send<T: Decodable>(_ ep: Endpoint) async throws -> T {
        guard var comps = URLComponents(url: baseURL.appendingPathComponent(ep.path),
                                        resolvingAgainstBaseURL: false)
        else { throw APIError.invalidURL }

        if !ep.query.isEmpty { comps.queryItems = ep.query }
        guard let url = comps.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = ep.method.rawValue
        req.httpBody = ep.body
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Access token ekle
        if let token = tokenStore.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        // Extra header'lar
        ep.headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        
        // Debug bilgisi
        print("🌐 API Request: \(req.httpMethod ?? "UNKNOWN") \(url)")
        if let body = ep.body, let bodyString = String(data: body, encoding: .utf8) {
            print("📤 Request Body: \(bodyString)")
        }

        do {
            let (data, resp) = try await urlSession.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw APIError.unknown }

            print("📥 Response Status: \(http.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
            }

            switch http.statusCode {
            case 200...299:
                if T.self == EmptyResponse.self { return EmptyResponse() as! T }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("❌ Decoding failed: \(error)")
                    throw APIError.decoding(error)
                }
            case 401:
                // Access token geçersiz, refresh token ile yenilemeyi dene
                if let refreshToken = tokenStore.refreshToken {
                    do {
                        let refreshResult = try await refreshAccessToken(refreshToken)
                        tokenStore.accessToken = refreshResult.accessToken
                        
                        // Yeni token ile isteği tekrarla
                        req.setValue("Bearer \(refreshResult.accessToken)", forHTTPHeaderField: "Authorization")
                        return try await send(ep)
                    } catch {
                        // Refresh token da geçersiz, kullanıcıyı çıkış yaptır
                        tokenStore.clear()
                        throw APIError.unauthorized
                    }
                } else {
                    throw APIError.unauthorized
                }
            case 404: throw APIError.notFound
            default:
                let body = String(data: data, encoding: .utf8)
                throw APIError.server(status: http.statusCode, body: body)
            }
        } catch {
            if let e = error as? APIError { throw e }
            throw APIError.network(error)
        }
    }
}

struct EmptyResponse: Decodable {}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
}

extension APIClient {
    private func refreshAccessToken(_ refreshToken: String) async throws -> RefreshTokenResponse {
        var ep = Endpoint(path: "api/Auth/refresh-token", method: .POST)
        ep.body = try JSONEncoder().encode(["refreshToken": refreshToken])
        
        return try await send(ep)
    }
}

