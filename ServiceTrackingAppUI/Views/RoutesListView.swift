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
                    "Hiç güzergah yok",
                    systemImage: "map",
                    description: Text("Aşağı çekerek yenileyebilir veya veri ekledikten sonra tekrar deneyebilirsin.")
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
                            // Göster işlevi - detay sayfasına yönlendirme eklenebilir
                            print("Route detayı göster: \(route.routeName)")
                        }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Sil", role: .destructive) {
                            routeToDelete = route
                            showingDeleteAlert = true
                        }
                        
                        Button("Düzenle") {
                            editingRoute = route
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button("Düzenle", systemImage: "pencil") {
                            editingRoute = route
                        }
                        
                        Button("Sil", systemImage: "trash", role: .destructive) {
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
                Button("Ekle", systemImage: "plus") {
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
        .alert("Güzergahı Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                if let route = routeToDelete {
                    Task {
                        await vm.delete(id: route.id)
                    }
                }
                routeToDelete = nil
            }
        } message: {
            if let route = routeToDelete {
                Text("'\(route.routeName)' güzergahını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
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