//
//  ShiftsListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct ShiftsListView: View {
    @StateObject private var vm = ShiftsViewModel(service: ShiftService())

    var body: some View {
        Group {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView(
                    "Hiç vardiya yok",
                    systemImage: "clock",
                    description: Text("Aşağı çekerek yenileyebilir veya veri ekledikten sonra tekrar deneyebilirsin.")
                )
            } else {
                List(vm.items) { shift in
                    ShiftRow(shift: shift)
                }
                .listStyle(.plain)
                .refreshable { vm.load() }
            }
        }
        .overlay {
            if vm.isLoading { ProgressView().scaleEffect(1.2) }
        }
        .navigationTitle("Shifts")
        .task { if vm.items.isEmpty { vm.load() } }
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