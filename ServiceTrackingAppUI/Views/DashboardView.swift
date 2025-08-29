//
//  DashboardView.swift
//  ServiceTrackingAppUI
//
//  Created by AI on 29.08.2025.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    statsRow
                    pendingTasksCard
                    quickActions
                    systemOverview
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.white)
            .navigationTitle("Dashboard")
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
    }

    // MARK: - Sections

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(title: "Total Vehicles", value: "25", systemImage: "bus")
            StatCard(title: "Active Drivers", value: "18", systemImage: "steeringwheel")
        }
    }

    private var pendingTasksCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pending Tasks")
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundColor(.secondary)
            Text("7")
                .font(.custom("Poppins-Bold", size: 28))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.custom("Poppins-SemiBold", size: 16))
            HStack(spacing: 12) {
                PrimaryActionButton(title: "Add Vehicle", icon: "plus.circle") {}
                SecondaryActionButton(title: "Assign Task", icon: "checkmark.circle") {}
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private var systemOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("System Overview")
                .font(.custom("Poppins-SemiBold", size: 16))

            OverviewRow(icon: "person.2", title: "User Management", subtitle: "Manage user roles and permissions")
            OverviewRow(icon: "doc.text", title: "Reports", subtitle: "Generate usage and completion reports")
            OverviewRow(icon: "gearshape", title: "Settings", subtitle: "Configure system preferences")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Components

private struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundColor(.red)
                Text(title)
                    .font(.custom("Poppins-Medium", size: 13))
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.custom("Poppins-Bold", size: 28))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

private struct OverviewRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 28, height: 28)
                .foregroundColor(.red)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.custom("Poppins-Medium", size: 15))
                Text(subtitle).font(.custom("Poppins-Regular", size: 12)).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct PrimaryActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 14))
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(LinearGradient(colors: [Color.red, Color.red.opacity(0.85)], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.red.opacity(0.25), radius: 6, x: 0, y: 3)
        }
    }
}

private struct SecondaryActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 14))
            }
            .foregroundColor(.red)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview { DashboardView().environmentObject(AppState()) }


