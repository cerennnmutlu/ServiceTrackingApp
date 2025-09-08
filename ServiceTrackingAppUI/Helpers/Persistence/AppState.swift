//
//  AppState.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation

//Değişiklikleri izlemek ve tepki vermek için (reactive programming framework'ü)
import Combine

final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool
    init(isAuthenticated: Bool = KeychainTokenStore.shared.accessToken != nil) {
        self.isAuthenticated = isAuthenticated
    }
    func logout() {
        KeychainTokenStore.shared.clear()
        isAuthenticated = false
    }
}
