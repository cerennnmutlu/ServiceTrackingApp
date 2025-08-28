//
//  Encodable+Body.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//


//Encodable struct'ı -> JSON formatına çevirdik.
import Foundation
extension Encodable {
    func toJSONData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
