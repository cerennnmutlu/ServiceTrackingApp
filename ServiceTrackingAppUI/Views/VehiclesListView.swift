//
//  VehiclesListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct VehiclesListView: View {
    @StateObject private var vm = VehiclesViewModel(service: VehicleService())

    var body: some View {
        Group {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView(
                    "Hiç araç yok",
                    systemImage: "bus",
                    description: Text("Aşağı çekerek yenileyebilir veya veri ekledikten sonra tekrar deneyebilirsin.")
                )
            } else {
                List(vm.items) { vehicle in
                    VehicleRow(vehicle: vehicle)
                }
                .listStyle(.plain)
                .refreshable { vm.loadSync() }
            }
        }
        .overlay {
            if vm.isLoading { ProgressView().scaleEffect(1.2) }
        }
        .navigationTitle("Vehicles")
        .task { if vm.items.isEmpty { vm.loadSync() } }
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
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bus.fill")
                .imageScale(.large)
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.plateNumber).font(.headline)
                HStack(spacing: 8) {
                    Text("#\(vehicle.id)").font(.caption).foregroundStyle(.secondary)
                    if let brand = vehicle.brand, !brand.isEmpty {
                        Text(brand).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(.thinMaterial).cornerRadius(6)
                    }
                    if let status = vehicle.status, !status.isEmpty {
                        Text(status).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(status == "Active" ? .green.opacity(0.2) : .orange.opacity(0.2))
                            .foregroundColor(status == "Active" ? .green : .orange)
                            .cornerRadius(6)
                    }
                }
                if let model = vehicle.model, !model.isEmpty {
                    Text(model).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Kapasite: \(vehicle.capacity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}