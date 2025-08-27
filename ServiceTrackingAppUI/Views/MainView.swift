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

            // DRIVERS
            NavigationStack {
                DriversListView()
                    .navigationTitle("Drivers")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(role: .destructive) {
                                appState.logout()
                            } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                            .accessibilityLabel("Logout")
                        }
                    }
            }
            .tabItem { Label("Drivers", systemImage: "steeringwheel") }
            .tag(0)

            // VEHICLES (placeholder - sonra bağlayacağız)
            NavigationStack { VehiclesPlaceholder() }
                .tabItem { Label("Vehicles", systemImage: "bus") }
                .tag(1)

            // ROUTES (placeholder)
            NavigationStack { RoutesPlaceholder() }
                .tabItem { Label("Routes", systemImage: "map") }
                .tag(2)

            // SHIFTS (placeholder)
            NavigationStack { ShiftsPlaceholder() }
                .tabItem { Label("Shifts", systemImage: "clock") }
                .tag(3)

            // TRACKINGS (placeholder)
            NavigationStack { TrackingsPlaceholder() }
                .tabItem { Label("Trackings", systemImage: "location") }
                .tag(4)
        }
    }
}

// Placeholder görünümleri (iOS 17+)
private struct VehiclesPlaceholder: View {
    var body: some View {
        ContentUnavailableView(
            "Vehicles henüz hazır değil",
            systemImage: "hammer",
            description: Text("Önce ServiceVehicleService ve ViewModel’i ekleyelim.")
        )
        .navigationTitle("Vehicles")
    }
}
private struct RoutesPlaceholder: View {
    var body: some View {
        ContentUnavailableView("Routes henüz hazır değil", systemImage: "hammer")
            .navigationTitle("Routes")
    }
}
private struct ShiftsPlaceholder: View {
    var body: some View {
        ContentUnavailableView("Shifts henüz hazır değil", systemImage: "hammer")
            .navigationTitle("Shifts")
    }
}
private struct TrackingsPlaceholder: View {
    var body: some View {
        ContentUnavailableView("Trackings henüz hazır değil", systemImage: "hammer")
            .navigationTitle("Trackings")
    }
}
