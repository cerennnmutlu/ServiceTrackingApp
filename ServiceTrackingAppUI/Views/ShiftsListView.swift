//
//  ShiftsListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct ShiftsListView: View {
    @StateObject private var shiftsVM = ShiftsViewModel(service: ShiftService())
    @StateObject private var routesVM = RoutesViewModel(service: RouteService())
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Tab", selection: $selectedTab) {
                Text("Shifts").tag(0)
                Text("Routes").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            TabView(selection: $selectedTab) {
                // SHIFTS TAB
                Group {
                    if shiftsVM.items.isEmpty && !shiftsVM.isLoading {
                        ContentUnavailableView(
                            "Hiç vardiya yok",
                            systemImage: "clock",
                            description: Text("Aşağı çekerek yenileyebilir veya veri ekledikten sonra tekrar deneyebilirsin.")
                        )
                    } else {
                        List(shiftsVM.items) { shift in
                            ShiftRow(shift: shift)
                        }
                        .listStyle(.plain)
                        .refreshable { shiftsVM.load() }
                    }
                }
                .overlay {
                    if shiftsVM.isLoading { ProgressView().scaleEffect(1.2) }
                }
                .tag(0)
                
                // ROUTES TAB
                Group {
                    if routesVM.items.isEmpty && !routesVM.isLoading {
                        ContentUnavailableView(
                            "Hiç güzergah yok",
                            systemImage: "map",
                            description: Text("Aşağı çekerek yenileyebilir veya veri ekledikten sonra tekrar deneyebilirsin.")
                        )
                    } else {
                        List(routesVM.items) { route in
                            RouteRow(route: route)
                        }
                        .listStyle(.plain)
                        .refreshable { routesVM.load() }
                    }
                }
                .overlay {
                    if routesVM.isLoading { ProgressView().scaleEffect(1.2) }
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(selectedTab == 0 ? "Shifts" : "Routes")
        .task {
            if shiftsVM.items.isEmpty { shiftsVM.load() }
            if routesVM.items.isEmpty { routesVM.load() }
        }
        .alert("Error",
               isPresented: Binding(
                get: { shiftsVM.error != nil || routesVM.error != nil },
                set: { _ in shiftsVM.error = nil; routesVM.error = nil })
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(shiftsVM.error ?? routesVM.error ?? "")
        }
    }
}

struct RouteRow: View {
    let route: RouteModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.routeName)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let status = route.status {
                    Text(status)
                        .font(.custom("Poppins-Regular", size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(status == "Active" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundColor(status == "Active" ? .green : .red)
                        .cornerRadius(8)
                }
            }
            
            if let description = route.description {
                Text(description)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                if let distance = route.distance {
                    Label("\(String(format: "%.1f", distance)) km", systemImage: "road.lanes")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.secondary)
                }
                
                if let duration = route.estimatedDuration {
                    Label("\(duration) dk", systemImage: "clock")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ShiftsListView()
    }
}

private struct ShiftRow: View {
    let shift: Shift
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .imageScale(.large)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(shift.shiftName).font(.headline)
                HStack(spacing: 8) {
                    Text("#\(shift.id)").font(.caption).foregroundStyle(.secondary)
                    if let status = shift.status, !status.isEmpty {
                        Text(status).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(status == "Active" ? .green.opacity(0.2) : .orange.opacity(0.2))
                            .foregroundColor(status == "Active" ? .green : .orange)
                            .cornerRadius(6)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(shift.startTime) - \(shift.endTime)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}