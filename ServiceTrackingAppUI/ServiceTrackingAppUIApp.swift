//
//  ServiceTrackingAppUIApp.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

@main
struct ServiceTrackingAppUIApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            // ContentView kullanıyorsan:
            ContentView()
                .environmentObject(appState)

            // veya SplashView kullanıyorsan:
            // SplashView()
            //     .environmentObject(appState)
        }
    }
}


