//
//  MainView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

// Views/MainView.swift
import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {

            // DASHBOARD
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house") }
                .tag(0)

            // VEHICLES & DRIVERS
            NavigationStack {
                VehiclesDriversListView()
            }
            .tabItem { Label("Vehicles & Drivers", systemImage: "bus") }
            .tag(1)

            // SHIFTS
            NavigationStack {
                ShiftsListView()
                    .navigationTitle("Shifts")
            }
            .tabItem { Label("Shifts & Routes", systemImage: "clock") }
            .tag(2)

            // PROFILE
            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.circle") }
            .tag(3)
        }
        .tint(.red) // Tema: seçili tab ve kontroller kırmızı
    }
}

// Placeholder görünümleri (iOS 17+)
private struct TrackingsPlaceholder: View {
    var body: some View {
        ContentUnavailableView("Trackings henüz hazır değil", systemImage: "hammer")
            .navigationTitle("Trackings")
    }
}
