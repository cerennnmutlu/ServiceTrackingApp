//
//  APIError.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case notFound
    case server(status: Int, body: String?) 
    case decoding(Error) //JSON parse edilememiş.
    case network(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Geçersiz URL."
        case .unauthorized: return "Yetkisiz. Lütfen tekrar giriş yapın."
        case .notFound: return "Kaynak bulunamadı."
        case .server(let s, _): return "Sunucu hatası (\(s))."
        case .decoding(let e): return "Veri çözümlenemedi: \(e.localizedDescription)"
        case .network(let e): return "Ağ hatası: \(e.localizedDescription)"
        case .unknown: return "Bilinmeyen hata."
        }
    }
}
