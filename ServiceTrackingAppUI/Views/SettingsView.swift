//
//  SettingsView.swift
//  ServiceTrackingAppUI
//
//  Created by AI on 29.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var notificationsEnabled = false
    @State private var theme: String = "System"

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink("Update Profile") { Text("Update Profile") }
                    NavigationLink("Change Password") { Text("Change Password") }
                }

                Section("App Preferences") {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                    HStack {
                        Text("Theme")
                        Spacer()
                        Text(theme).foregroundColor(.secondary)
                    }
                }

                Section("Support") {
                    NavigationLink("Help Center") { Text("Help Center") }
                    NavigationLink("Contact Support") { Text("Contact Support") }
                }
            }
            .navigationTitle("Settings")
            .tint(.red)
        }
    }
}

#Preview { SettingsView().environmentObject(AppState()) }


