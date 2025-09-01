//
//  RoutesListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct RoutesListView: View {
    @StateObject private var vm = RoutesViewModel(service: RouteService())
    @State private var showingAddSheet = false
    @State private var editingRoute: RouteModel?
    @State private var routeToDelete: RouteModel?
    @State private var showingDeleteAlert = false

    var body: some View {
        Group {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView(
                    "No Routes",
                    systemImage: "map",
                    description: Text("Pull to refresh or add data and try again.")
                )
            } else {
                List(vm.items) { route in
                    RouteRow(
                        route: route,
                        onEdit: {
                            editingRoute = route
                        },
                        onDelete: {
                            routeToDelete = route
                            showingDeleteAlert = true
                        },
                        onShow: {
                            // Show function - can redirect to detail page
                            print("Show route details: \(route.routeName)")
                        }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            routeToDelete = route
                            showingDeleteAlert = true
                        }
                        
                        Button("Edit") {
                            editingRoute = route
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            editingRoute = route
                        }
                        
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            routeToDelete = route
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
        .navigationTitle("Routes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add", systemImage: "plus") {
                    showingAddSheet = true
                }
                .font(.custom("Poppins-Medium", size: 16))
            }
        }
        .task { if vm.items.isEmpty { vm.loadSync() } }
        .sheet(isPresented: $showingAddSheet) {
            RouteFormView(viewModel: vm)
        }
        .sheet(item: $editingRoute) { route in
            RouteFormView(viewModel: vm, editingRoute: route)
        }
        .alert("Delete Route", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let route = routeToDelete {
                    Task {
                        await vm.delete(id: route.id)
                    }
                }
                routeToDelete = nil
            }
        } message: {
            if let route = routeToDelete {
                Text("Are you sure you want to delete '\(route.routeName)'? This action cannot be undone.")
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

#Preview {
    NavigationStack {
        RoutesListView()
    }
}