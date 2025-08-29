//
//  RoutesListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct RoutesListView: View {
    @StateObject private var vm = RoutesViewModel(service: RouteService())

    var body: some View {
        Group {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView(
                    "Hiç güzergah yok",
                    systemImage: "map",
                    description: Text("Aşağı çekerek yenileyebilir veya veri ekledikten sonra tekrar deneyebilirsin.")
                )
            } else {
                List(vm.items) { route in
                    RouteRow(route: route)
                }
                .listStyle(.plain)
                .refreshable { vm.load() }
            }
        }
        .overlay {
            if vm.isLoading { ProgressView().scaleEffect(1.2) }
        }
        .navigationTitle("Routes")
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

#Preview {
    NavigationStack {
        RoutesListView()
    }
}