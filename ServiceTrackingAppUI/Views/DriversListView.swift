//
//  DriversListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//


import SwiftUI

struct DriversListView: View {
    @StateObject private var vm = DriversViewModel(service: DriverService())

    var body: some View {
        Group {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView(
                    "Hiç şoför yok",
                    systemImage: "person.text.rectangle",
                    description: Text("Aşağı çekerek yenileyebilir veya veri ekledikten sonra tekrar deneyebilirsin.")
                )
            } else {
                List(vm.items) { d in
                    DriverRow(driver: d)
                }
                .listStyle(.plain)
                .refreshable { vm.loadSync() }
            }
        }
        .overlay {
            if vm.isLoading { ProgressView().scaleEffect(1.2) }
        }
        .navigationTitle("Drivers")
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

private struct DriverRow: View {
    let driver: Driver
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill")
                .imageScale(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text(driver.fullName).font(.headline)
                HStack(spacing: 8) {
                    Text("#\(driver.id)").font(.caption).foregroundStyle(.secondary)
                    if let status = driver.status, !status.isEmpty {
                        Text(status).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(.thinMaterial).cornerRadius(6)
                    }
                }
            }
            Spacer()
            if let phone = driver.phone, !phone.isEmpty {
                Text(phone).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
