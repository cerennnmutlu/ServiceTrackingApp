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
        self._viewModel = StateObject(wrappedValue: DashboardViewModel(authService: authService))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    welcomeHeader
                    
                    // Stats Grid
                    statsGrid
                    
                    // Pending Tasks
                    pendingTasksCard
                    
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
                    Button(action: {}) {
                        Image(systemName: "gearshape")
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
                Text("👋 Hoşgeldin, \(viewModel.userName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Text("Bugün \(viewModel.stats.activeVehicles) araç aktif")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Araç durumu kartları - eşit boyutlarda
            HStack(spacing: 12) {
                VehicleStatusCard(title: "Aktif", count: 6, color: .green)
                VehicleStatusCard(title: "Vardiyada", count: 3, color: .blue)
                VehicleStatusCard(title: "Beklemede", count: 3, color: .orange)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            // Total Vehicles Card
            SimpleStatCard(
                title: "Total Vehicles",
                value: "25",
                backgroundColor: Color(.systemBackground)
            )
            
            // Active Drivers Card
            SimpleStatCard(
                title: "Active Drivers",
                value: "18",
                backgroundColor: Color(.systemBackground)
            )
        }
    }

    // MARK: - Pending Tasks Card
    private var pendingTasksCard: some View {
        SimpleStatCard(
            title: "Pending Tasks",
            value: "7",
            backgroundColor: Color(.systemBackground)
        )
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
                QuickActionButton(
                    icon: "+",
                    title: "Entry Record",
                    color: .blue
                ) {
                    // Handle entry record
                }
                
                QuickActionButton(
                    icon: "+",
                    title: "Exit Record",
                    color: .blue
                ) {
                    // Handle exit record
                }
                
                QuickActionButton(
                    icon: "🚌",
                    title: "New Vehicle",
                    color: .blue
                ) {
                    // Handle new vehicle
                }
                
                QuickActionButton(
                    icon: "👥",
                    title: "New Driver",
                    color: .blue
                ) {
                    // Handle new driver
                }
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

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(8)
        }
    }
}

struct SimpleStatCard: View {
    let title: String
    let value: String
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
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
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}



#Preview {
    DashboardView()
}


