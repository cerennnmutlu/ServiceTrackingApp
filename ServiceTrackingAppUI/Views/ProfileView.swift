//
//  ProfileView.swift
//  ServiceTrackingAppUI
//
//  Created by AI on 29.08.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .foregroundColor(.red)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.user?.fullName ?? "-")
                                .font(.custom("Poppins-SemiBold", size: 18))
                            Text(viewModel.user?.username ?? "-")
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                }

                Section("Personal Information") {
                    LabeledContent("Email", value: viewModel.user?.email ?? "-")
                    LabeledContent("Role ID", value: viewModel.user?.roleID.map(String.init) ?? "-")
                }

                // Settings sadece profil içinde
                Section("Settings") {
                    Toggle("Notifications", isOn: $viewModel.notificationsEnabled)
                    Button(role: .destructive) { appState.logout() } label: {
                        HStack { Text("Logout"); Spacer(); Image(systemName: "chevron.right") }
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button { viewModel.loadMe() } label: { Image(systemName: "arrow.clockwise") }
                        NavigationLink(destination: SettingsView()) { Image(systemName: "gearshape") }
                    }
                }
            }
            .task { if viewModel.user == nil { viewModel.loadMe() } }
        }
    }
}

#Preview { ProfileView().environmentObject(AppState()) }


