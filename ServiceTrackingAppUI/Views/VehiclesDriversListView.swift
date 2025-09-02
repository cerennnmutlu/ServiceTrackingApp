//
//  VehiclesDriversListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct VehiclesDriversListView: View {
    @StateObject private var vehiclesVM = VehiclesViewModel(service: VehicleService())
    @StateObject private var driversVM = DriversViewModel(service: DriverService())
    @StateObject private var routesViewModel = RoutesViewModel(service: RouteService())
    @State private var selectedTab = 0
    
    // Vehicle CRUD states
    @State private var showingAddVehicleSheet = false
    @State private var editingVehicle: ServiceVehicle?
    @State private var vehicleToDelete: ServiceVehicle?
    @State private var showingDeleteVehicleAlert = false
    
    // Driver CRUD states
    @State private var showingAddDriverSheet = false
    @State private var editingDriver: Driver?
    @State private var driverToDelete: Driver?
    @State private var showingDeleteDriverAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Picker("Tab", selection: $selectedTab) {
                Text("Vehicles").tag(0)
                Text("Drivers").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            TabView(selection: $selectedTab) {
                // VEHICLES TAB
                Group {
                    if vehiclesVM.items.isEmpty && !vehiclesVM.isLoading {
                        ContentUnavailableView(
                            "No Vehicles",
                            systemImage: "car",
                            description: Text("Pull down to refresh or try again after adding data.")
                        )
                    } else {
                        List(vehiclesVM.items) { vehicle in
                            VehicleRow(
                                vehicle: vehicle,
                                routesViewModel: routesViewModel,
                                onEdit: {
                                    editingVehicle = vehicle
                                },
                                onDelete: {
                                    vehicleToDelete = vehicle
                                    showingDeleteVehicleAlert = true
                                },
                                onShow: {
                                    // Show function - can redirect to detail page
                                    print("Show vehicle details: \(vehicle.plateNumber)")
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    vehicleToDelete = vehicle
                                    showingDeleteVehicleAlert = true
                                }
                                Button("Edit") {
                                    editingVehicle = vehicle
                                }
                                .tint(.blue)
                            }
                            .contextMenu {
                                Button("Edit", systemImage: "pencil") {
                                    editingVehicle = vehicle
                                }
                                
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    vehicleToDelete = vehicle
                                    showingDeleteVehicleAlert = true
                                }
                            }
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.visible, edges: .all)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparatorTint(.gray.opacity(0.3))
                        .refreshable { vehiclesVM.loadSync() }
                    }
                }
                .overlay {
                    if vehiclesVM.isLoading { ProgressView().scaleEffect(1.2) }
                }
                .tag(0)
                
                // DRIVERS TAB
                Group {
                    if driversVM.items.isEmpty && !driversVM.isLoading {
                        ContentUnavailableView(
                            "No Drivers",
                            systemImage: "person.text.rectangle",
                            description: Text("Pull down to refresh or try again after adding data.")
                        )
                    } else {
                        List(driversVM.items) { driver in
                            DriverRow(
                                driver: driver,
                                onEdit: {
                                    editingDriver = driver
                                },
                                onDelete: {
                                    driverToDelete = driver
                                    showingDeleteDriverAlert = true
                                },
                                onShow: {
                                    // Show function - can redirect to detail page
                                    print("Show driver details: \(driver.fullName)")
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    driverToDelete = driver
                                    showingDeleteDriverAlert = true
                                }
                                Button("Edit") {
                                    editingDriver = driver
                                }
                                .tint(.blue)
                            }
                            .contextMenu {
                                Button("Edit", systemImage: "pencil") {
                                    editingDriver = driver
                                }
                                
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    driverToDelete = driver
                                    showingDeleteDriverAlert = true
                                }
                            }
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.visible, edges: .all)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparatorTint(.gray.opacity(0.3))
                        .refreshable { driversVM.loadSync() }
                    }
                }
                .overlay {
                    if driversVM.isLoading { ProgressView().scaleEffect(1.2) }
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(selectedTab == 0 ? "Vehicles" : "Drivers")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add", systemImage: "plus") {
                    if selectedTab == 0 {
                        showingAddVehicleSheet = true
                    } else {
                        showingAddDriverSheet = true
                    }
                }
                .font(.custom("Poppins-Medium", size: 16))
            }
        }
        .task {
            if vehiclesVM.items.isEmpty { vehiclesVM.loadSync() }
            if driversVM.items.isEmpty { driversVM.loadSync() }
            await routesViewModel.load()
        }
        // Vehicle sheets and alerts
        .sheet(isPresented: $showingAddVehicleSheet) {
            VehicleFormView(viewModel: vehiclesVM)
        }
        .sheet(item: $editingVehicle) { vehicle in
            VehicleFormView(viewModel: vehiclesVM, editingVehicle: vehicle)
        }
        .alert("Delete Vehicle", isPresented: $showingDeleteVehicleAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let vehicle = vehicleToDelete {
                    Task {
                        let success = await vehiclesVM.delete(id: vehicle.id)
                        if success {
                            await vehiclesVM.load()
                        }
                    }
                }
                vehicleToDelete = nil
            }
        } message: {
            if let vehicle = vehicleToDelete {
                Text("Are you sure you want to delete '\(vehicle.plateNumber)'? This action cannot be undone.")
            }
        }
        
        // Driver sheets and alerts
        .sheet(isPresented: $showingAddDriverSheet) {
            DriverFormView(viewModel: driversVM)
        }
        .sheet(item: $editingDriver) { driver in
            DriverFormView(viewModel: driversVM, editingDriver: driver)
        }
        .alert("Delete Driver", isPresented: $showingDeleteDriverAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let driver = driverToDelete {
                    Task {
                        await driversVM.delete(id: driver.id)
                    }
                }
                driverToDelete = nil
            }
        } message: {
            if let driver = driverToDelete {
                Text("Are you sure you want to delete '\(driver.fullName)'? This action cannot be undone.")
            }
        }
        .alert("Error",
               isPresented: Binding(
                get: { vehiclesVM.error != nil || driversVM.error != nil },
                set: { _ in vehiclesVM.error = nil; driversVM.error = nil })
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vehiclesVM.error ?? driversVM.error ?? "")
        }
    }
}

struct VehicleRow: View {
    let vehicle: ServiceVehicle
    let routesViewModel: RoutesViewModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onShow: () -> Void
    
    private var routeName: String {
        routesViewModel.items.first { $0.id == vehicle.routeID }?.routeName ?? "Unknown Route"
    }
    
    private func statusBackgroundColor(for status: String) -> Color {
        switch status.lowercased() {
        case "active":
            return Color.green.opacity(0.2)
        case "inactive":
            return Color.red.opacity(0.2)
        case "maintenance":
            return Color.orange.opacity(0.2)
        default:
            return Color.gray.opacity(0.2)
        }
    }
    
    private func statusForegroundColor(for status: String) -> Color {
        switch status.lowercased() {
        case "active":
            return .green
        case "inactive":
            return .red
        case "maintenance":
            return .orange
        default:
            return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bus.fill")
                .imageScale(.large)
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.plateNumber)
                    .font(.headline)
                
                // Brand and Model
                if let brand = vehicle.brand, !brand.isEmpty,
                   let model = vehicle.model, !model.isEmpty {
                    Text("\(brand) - \(model)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if let brand = vehicle.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if let model = vehicle.model, !model.isEmpty {
                    Text(model)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Status
                if let status = vehicle.status, !status.isEmpty {
                    Text(status)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusBackgroundColor(for: status))
                        .foregroundColor(statusForegroundColor(for: status))
                        .cornerRadius(8)
                }
                
                // Capacity
                Text("Capacity: \(vehicle.capacity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // Route
                Text("Route: \(routeName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .onTapGesture { onEdit() }
    }
}

struct DriverRow: View {
    let driver: Driver
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onShow: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill")
                .imageScale(.large)
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text(driver.fullName).font(.headline)
                if let phone = driver.phone, !phone.isEmpty {
                    Text(phone).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let status = driver.status, !status.isEmpty {
                Text(status)
                    .font(.custom("Poppins-Regular", size: 12))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(status == "Active" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(status == "Active" ? .green : .red)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 6)
        .onTapGesture { onEdit() }
    }
}

#Preview {
    NavigationStack {
        VehiclesDriversListView()
    }
}