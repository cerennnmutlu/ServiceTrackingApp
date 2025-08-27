//
//  _CodingHelpers.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

/// JSON, PascalCase (DriverID) ya da camelCase (driverID) dönebilir.
/// Bu yardımcı, birden fazla anahtarı sırayla deneyip ilkini çözer.
struct AnyCodingKey: CodingKey {
    var stringValue: String; init(_ s: String) { stringValue = s }
    init?(stringValue: String) { self.stringValue = stringValue }
    var intValue: Int? = nil
    init?(intValue: Int) { return nil }
}

extension KeyedDecodingContainer where K == AnyCodingKey {
    func decodeFlexible<T: Decodable>(_ type: T.Type, keys: [String]) throws -> T {
        for k in keys {
            if let v = try? decode(T.self, forKey: AnyCodingKey(k)) { return v }
        }
        throw DecodingError.keyNotFound(AnyCodingKey(keys.first ?? "?"),
                                        .init(codingPath: codingPath, debugDescription: "none of keys found: \(keys)"))
    }
    func decodeFlexibleIfPresent<T: Decodable>(_ type: T.Type, keys: [String]) -> T? {
        for k in keys {
            if let v = try? decode(T.self, forKey: AnyCodingKey(k)) { return v }
        }
        return nil
    }
}
