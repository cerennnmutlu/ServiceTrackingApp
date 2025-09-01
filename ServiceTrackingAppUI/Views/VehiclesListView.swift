//
//  VehiclesListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct VehiclesListView: View {
    @StateObject private var vm = VehiclesViewModel(service: VehicleService())
    @StateObject private var routesViewModel = RoutesViewModel(service: RouteService())
    @State private var showingAddForm = false
    @State private var editingVehicle: ServiceVehicle?
    @State private var showingDeleteAlert = false
    @State private var vehicleToDelete: ServiceVehicle?

    var body: some View {
        Group {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView(
                    "No Vehicles",
                    systemImage: "car",
                    description: Text("Pull to refresh or add data and try again.")
                )
            } else {
                List(vm.items) { vehicle in
                    Button {
                        editingVehicle = vehicle
                    } label: {
                        VehicleRow(vehicle: vehicle, routesViewModel: routesViewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            vehicleToDelete = vehicle
                            showingDeleteAlert = true
                        }
                        Button("Edit") {
                            editingVehicle = vehicle
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button("Edit") {
                            editingVehicle = vehicle
                        }
                        Button("Delete", role: .destructive) {
                            vehicleToDelete = vehicle
                            showingDeleteAlert = true
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable { vm.loadSync() }
            }
        }
        .overlay {
            if vm.isLoading { ProgressView().scaleEffect(1.2) }
        }
        .navigationTitle("Vehicles")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task { 
            if vm.items.isEmpty { vm.loadSync() }
            await routesViewModel.load()
        }
        .sheet(isPresented: $showingAddForm) {
            VehicleFormView(viewModel: vm)
        }
        .sheet(item: $editingVehicle) { vehicle in
            VehicleFormView(viewModel: vm, editingVehicle: vehicle)
        }
        .alert("Delete Vehicle", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let vehicle = vehicleToDelete {
                    Task {
                        let success = await vm.delete(id: vehicle.id)
                        if success {
                            await vm.load()
                        }
                    }
                }
            }
        } message: {
            if let vehicle = vehicleToDelete {
                Text("Are you sure you want to delete '\(vehicle.plateNumber)'? This action cannot be undone.")
            }
        }
        .alert("Error",
               isPresented: Binding(
                get: { vm.error != nil },
                set: { _ in vm.error = nil })
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.error ?? "")
        }
    }
}

private struct VehicleRow: View {
    let vehicle: ServiceVehicle
    let routesViewModel: RoutesViewModel
    
    private var routeName: String {
        routesViewModel.items.first { $0.id == vehicle.routeID }?.routeName ?? "Unknown Route"
    }
    
    private func statusBackgroundColor(for status: String) -> Color {
        switch status {
        case "Active":
            return .green.opacity(0.2)
        case "Inactive":
            return .red.opacity(0.2)
        case "Maintenance":
            return .yellow.opacity(0.2)
        default:
            return .gray.opacity(0.2)
        }
    }
    
    private func statusForegroundColor(for status: String) -> Color {
        switch status {
        case "Active":
            return .green
        case "Inactive":
            return .red
        case "Maintenance":
            return .yellow
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
                
                // Brand - Model info under plate number
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
                // Status badge in top right
                if let status = vehicle.status, !status.isEmpty {
                    Text(status)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusBackgroundColor(for: status))
                        .foregroundColor(statusForegroundColor(for: status))
                        .cornerRadius(8)
                }
                
                // Capacity info under status badge
                Text("Capacity: \(vehicle.capacity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // Route name under capacity
                Text("Route: \(routeName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}