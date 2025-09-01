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

            // VEHICLES
            NavigationStack {
                VehiclesListView()
                    .navigationTitle("Vehicles")
            }
            .tabItem { Label("Vehicles", systemImage: "bus") }
            .tag(1)

            // DRIVERS
            NavigationStack {
                DriversListView()
                    .navigationTitle("Drivers")
            }
            .tabItem { Label("Drivers", systemImage: "steeringwheel") }
            .tag(2)

            // SHIFTS
            NavigationStack {
                ShiftsListView()
                    .navigationTitle("Shifts")
            }
            .tabItem { Label("Shifts & Routes", systemImage: "clock") }
            .tag(3)

            // PROFILE
            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.circle") }
            .tag(4)
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
