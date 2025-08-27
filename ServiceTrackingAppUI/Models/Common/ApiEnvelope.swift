//
//  ApiEnvelope.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

/// Hem "data" hem "Data" anahtarını destekler.
struct ApiList<T: Decodable>: Decodable {
    let data: [T]
    private enum CodingKeys: String, CodingKey {
        case dataLower = "data"
        case dataUpper = "Data"
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let v = try? c.decode([T].self, forKey: .dataLower) { data = v; return }
        if let v = try? c.decode([T].self, forKey: .dataUpper) { data = v; return }
        throw DecodingError.keyNotFound(CodingKeys.dataLower, .init(codingPath: decoder.codingPath, debugDescription: "data/Data key not found"))
    }
}
