//
//  Endpoint.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//
import Foundation

struct Endpoint {
    var path: String
    var method: HTTPMethod
    var query: [URLQueryItem] = []
    var body: Data? = nil
    var headers: [String:String] = [:]
}

