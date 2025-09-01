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
                                    // Göster işlevi - detay sayfasına yönlendirme eklenebilir
                                    print("Shift detayı göster: \(shift.shiftName)")
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Sil", role: .destructive) {
                                    shiftToDelete = shift
                                    showingDeleteShiftAlert = true
                                }
                                
                                Button("Düzenle") {
                                    editingShift = shift
                                }
                                .tint(.blue)
                            }
                            .contextMenu {
                                Button("Düzenle", systemImage: "pencil") {
                                    editingShift = shift
                                }
                                
                                Button("Sil", systemImage: "trash", role: .destructive) {
                                    shiftToDelete = shift
                                    showingDeleteShiftAlert = true
                                }
                            }
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
                                    // Göster işlevi - detay sayfasına yönlendirme eklenebilir
                                    print("Route detayı göster: \(route.routeName)")
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Sil", role: .destructive) {
                                    routeToDelete = route
                                    showingDeleteRouteAlert = true
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
                                    showingDeleteRouteAlert = true
                                }
                            }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Ekle", systemImage: "plus") {
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
            if shiftsVM.items.isEmpty { shiftsVM.load() }
            if routesVM.items.isEmpty { routesVM.load() }
        }
        // Shift sheets and alerts
        .sheet(isPresented: $showingAddShiftSheet) {
            ShiftFormView(viewModel: shiftsVM)
        }
        .sheet(item: $editingShift) { shift in
            ShiftFormView(viewModel: shiftsVM, editingShift: shift)
        }
        .alert("Vardiyayı Sil", isPresented: $showingDeleteShiftAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                if let shift = shiftToDelete {
                    Task {
                        await shiftsVM.delete(id: shift.id)
                    }
                }
                shiftToDelete = nil
            }
        } message: {
            if let shift = shiftToDelete {
                Text("'\(shift.shiftName)' vardiyasını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
            }
        }
        // Route sheets and alerts
        .sheet(isPresented: $showingAddRouteSheet) {
            RouteFormView(viewModel: routesVM)
        }
        .sheet(item: $editingRoute) { route in
            RouteFormView(viewModel: routesVM, editingRoute: route)
        }
        .alert("Güzergahı Sil", isPresented: $showingDeleteRouteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                if let route = routeToDelete {
                    Task {
                        await routesVM.delete(id: route.id)
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
                
                HStack(spacing: 12) {
                    Button(action: onShow) {
                        Image(systemName: "eye")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                    }
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.orange)
                            .font(.system(size: 16))
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                    }
                }
                
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
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onShow: () -> Void
    
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
                
                HStack(spacing: 12) {
                    Button(action: onShow) {
                        Image(systemName: "eye")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                    }
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.orange)
                            .font(.system(size: 16))
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}