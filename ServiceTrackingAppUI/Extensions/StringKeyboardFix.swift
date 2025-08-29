//
//  StringKeyboardFix.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 28.08.2025.
//

import Foundation

// MARK: - String Extension for Mac Keyboard Fix
extension String {
    func fixMacKeyboardInput() -> String {
        self
            .replacingOccurrences(of: "œ", with: "@")
            .replacingOccurrences(of: "/", with: ".")
            .replacingOccurrences(of: ":", with: ".")
            .replacingOccurrences(of: ";", with: ",")
            .replacingOccurrences(of: "ç", with: "c")
            .replacingOccurrences(of: "ş", with: "s")
            .replacingOccurrences(of: "ğ", with: "g")
            .replacingOccurrences(of: "ü", with: "u")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ı", with: "i")
            .replacingOccurrences(of: "İ", with: "I")
            .replacingOccurrences(of: "Ç", with: "C")
            .replacingOccurrences(of: "Ş", with: "S")
            .replacingOccurrences(of: "Ğ", with: "G")
            .replacingOccurrences(of: "Ü", with: "U")
            .replacingOccurrences(of: "Ö", with: "O")
    }
}
