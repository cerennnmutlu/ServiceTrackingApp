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
    
    // Shift CRUD states
    @State private var showingAddShiftSheet = false
    @State private var editingShift: Shift?
    @State private var shiftToDelete: Shift?
    @State private var showingDeleteShiftAlert = false
    
    // Route CRUD states
    @State private var showingAddRouteSheet = false
    @State private var editingRoute: RouteModel?
    @State private var routeToDelete: RouteModel?
    @State private var showingDeleteRouteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                            "No Shifts",
                            systemImage: "clock",
                            description: Text("Pull down to refresh or try again after adding data.")
                        )
                    } else {
                        List(shiftsVM.items) { shift in
                            ShiftRow(
                                shift: shift,
                                onEdit: {
                                    editingShift = shift
                                },
                                onDelete: {
                                    shiftToDelete = shift
                                    showingDeleteShiftAlert = true
                                },
                                onShow: {
                                    // Show function - can redirect to detail page
                                    print("Show shift details: \(shift.shiftName)")
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    shiftToDelete = shift
                                    showingDeleteShiftAlert = true
                                }
                            }
                            .contextMenu {
                                Button("Edit", systemImage: "pencil") {
                                    editingShift = shift
                                }
                                
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    shiftToDelete = shift
                                    showingDeleteShiftAlert = true
                                }
                            }
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.visible, edges: .all)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparatorTint(.gray.opacity(0.3))
                        .refreshable { shiftsVM.loadSync() }
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
                            "No Routes",
                            systemImage: "map",
                            description: Text("Pull down to refresh or try again after adding data.")
                        )
                    } else {
                        List(routesVM.items) { route in
                            RouteRow(
                                route: route,
                                onEdit: {
                                    editingRoute = route
                                },
                                onDelete: {
                                    routeToDelete = route
                                    showingDeleteRouteAlert = true
                                },
                                onShow: {
                                    // Show function - can redirect to detail page
                                    print("Show route details: \(route.routeName)")
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    routeToDelete = route
                                    showingDeleteRouteAlert = true
                                }
                            }
                            .contextMenu {
                                Button("Edit", systemImage: "pencil") {
                                    editingRoute = route
                                }
                                
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    routeToDelete = route
                                    showingDeleteRouteAlert = true
                                }
                            }
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.visible, edges: .all)
                        .listRowInsets(EdgeInsets())
                        .refreshable { routesVM.loadSync() }
                    }
                }
                .overlay {
                    if routesVM.isLoading { ProgressView().scaleEffect(1.2) }
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(selectedTab == 0 ? "Shifts" : "Routes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add", systemImage: "plus") {
                    if selectedTab == 0 {
                        showingAddShiftSheet = true
                    } else {
                        showingAddRouteSheet = true
                    }
                }
                .font(.custom("Poppins-Medium", size: 16))
            }
        }
        .task {
            if shiftsVM.items.isEmpty { shiftsVM.loadSync() }
            if routesVM.items.isEmpty { routesVM.loadSync() }
        }
        // Shift sheets and alerts
        .sheet(isPresented: $showingAddShiftSheet) {
            ShiftFormView(viewModel: shiftsVM)
        }
        .sheet(item: $editingShift) { shift in
            ShiftFormView(viewModel: shiftsVM, editingShift: shift)
        }
        .alert("Delete Shift", isPresented: $showingDeleteShiftAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let shift = shiftToDelete {
                    Task {
                        await shiftsVM.delete(id: shift.id)
                    }
                }
                shiftToDelete = nil
            }
        } message: {
            if let shift = shiftToDelete {
                Text("Are you sure you want to delete '\(shift.shiftName)' shift? This action cannot be undone.")
            }
        }
        // Route sheets and alerts
        .sheet(isPresented: $showingAddRouteSheet) {
            RouteFormView(viewModel: routesVM)
        }
        .sheet(item: $editingRoute) { route in
            RouteFormView(viewModel: routesVM, editingRoute: route)
        }
        .alert("Delete Route", isPresented: $showingDeleteRouteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let route = routeToDelete {
                    Task {
                        await routesVM.delete(id: route.id)
                    }
                }
                routeToDelete = nil
            }
        } message: {
            if let route = routeToDelete {
                Text("Are you sure you want to delete '\(route.routeName)' route? This action cannot be undone.")
            }
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
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onShow: () -> Void
    
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
            
            if let description = route.description, !description.isEmpty {
                Text(description)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            
            HStack(spacing: 12) { // mesafe ve süre blokları arasındaki boşluk
                if let distance = route.distance {
                    HStack(spacing: 6) { // ikon–metin arası boşluk
                        Image(systemName: "road.lanes")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.1f", distance)) km")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                if let duration = route.estimatedDuration {
                    HStack(spacing: 6) { // ikon–metin arası boşluk
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("\(duration) dk")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .onTapGesture { onEdit() }
    }
}

#Preview {
    NavigationStack {
        ShiftsListView()
    }
}

private struct ShiftRow: View {
    let shift: Shift
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onShow: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .imageScale(.large)
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text(shift.shiftName).font(.headline)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let status = shift.status, !status.isEmpty {
                    Text(status)
                        .font(.custom("Poppins-Regular", size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(status == "Active" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundColor(status == "Active" ? .green : .red)
                        .cornerRadius(8)
                }
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text("\(shift.startTime) - \(shift.endTime)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(.vertical, 6)
        .onTapGesture {
            onEdit()
        }
    }
}