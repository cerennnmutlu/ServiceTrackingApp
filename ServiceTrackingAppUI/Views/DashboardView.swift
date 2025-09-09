//
//  DashboardView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    
    init() {
        // AuthService'i AppState ile birlikte oluştur
        let appState = AppState()
        let authService = AuthService(appState: appState)
        self._viewModel = StateObject(wrappedValue: DashboardViewModel(
            trackingService: TrackingService(),
            authService: authService,
            vehicleService: VehicleService(),
            driverService: DriverService()
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    welcomeHeader
                    
                    // Stats Grid
                    statsGrid
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Weekly Chart
                    weeklyChartSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            .background(Color.white)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
            .task {
                await viewModel.loadDashboardData()
            }
            .refreshable {
                await viewModel.loadDashboardData()
            }
        }
    }

    // MARK: - Sections

    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("👋 Welcome, \(viewModel.userName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }


    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: 12) {
            
            // Vehicle and Driver Stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                // Total Active Vehicles
                SimpleStatCard(
                    title: "Active Vehicles",
                    value: "\(viewModel.stats.activeVehicles)",
                    backgroundColor: Color(.systemBackground),
                    subtitle: "Total"
                )
                
                // Total Active Drivers
                SimpleStatCard(
                    title: "Active Drivers",
                    value: "\(viewModel.stats.activeDrivers)",
                    backgroundColor: Color(.systemBackground),
                    subtitle: "Total"
                )
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("⚡ Quick Actions")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                NavigationLink(destination: TrackingListView()) {
                    QuickActionCard(
                        icon: "📝",
                        title: "Entry Record",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: TrackingListView()) {
                    QuickActionCard(
                        icon: "📤",
                        title: "Exit Record",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: VehicleFormView()) {
                    QuickActionCard(
                        icon: "🚌",
                        title: "New Vehicle",
                        color: .orange
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: DriverFormView()) {
                    QuickActionCard(
                        icon: "👥",
                        title: "New Driver",
                        color: .purple
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Weekly Chart
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📊 This Week's Vehicle Movements")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Chart {
                ForEach(Array(zip(viewModel.weeklyData.indices, viewModel.weeklyData)), id: \.0) { index, value in
                    BarMark(
                        x: .value("Day", dayLabels[index]),
                        y: .value("Movements", value)
                    )
                    .foregroundStyle(Color.blue)
                    .cornerRadius(4)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...30)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

}

// MARK: - Supporting Views

struct DetailedStatCard: View {
    let icon: String
    let title: String
    let totalCount: Int
    let activeCount: Int
    let inactiveCount: Int
    let activeLabel: String
    let inactiveLabel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // Total Count
            Text("\(totalCount)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            // Active/Inactive Stats
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(activeLabel + ": \(activeCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(inactiveLabel + ": \(inactiveCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ShiftStatCard: View {
    let icon: String
    let title: String
    let totalCount: Int
    let morningCount: Int
    let eveningCount: Int
    let nightCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // Total Count
            Text("\(totalCount)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            // Shift Stats
            VStack(alignment: .leading, spacing: 2) {
                Text("Morning: \(morningCount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Text("Evening: \(eveningCount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Text("Night: \(nightCount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct SimpleStatCard: View {
    let title: String
    let value: String
    let backgroundColor: Color
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct SystemOverviewRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct VehicleStatusCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title2)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}



#Preview {
    DashboardView()
}


