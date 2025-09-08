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
    
    // Date decoding with multiple strategies
    func decodeFlexibleDate(keys: [String]) throws -> Date {
        for k in keys {
            if let dateString = try? decode(String.self, forKey: AnyCodingKey(k)) {
                // Try different date formats
                let formatters = [
                    ISO8601DateFormatter(),
                    {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        return formatter
                    }(),
                    {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        return formatter
                    }(),
                    {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        return formatter
                    }()
                ]
                
                for formatter in formatters {
                    if let isoFormatter = formatter as? ISO8601DateFormatter {
                        if let date = isoFormatter.date(from: dateString) {
                            return date
                        }
                    } else if let dateFormatter = formatter as? DateFormatter {
                        if let date = dateFormatter.date(from: dateString) {
                            return date
                        }
                    }
                }
            }
            
            // Try direct Date decoding as fallback
            if let date = try? decode(Date.self, forKey: AnyCodingKey(k)) {
                return date
            }
        }
        throw DecodingError.keyNotFound(AnyCodingKey(keys.first ?? "?"),
                                        .init(codingPath: codingPath, debugDescription: "none of keys found: \(keys)"))
    }
    
    func decodeFlexibleDateIfPresent(keys: [String]) -> Date? {
        return try? decodeFlexibleDate(keys: keys)
    }
}
