//
//  DriversListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//


import SwiftUI

struct DriversListView: View {
    @StateObject private var vm = DriversViewModel(service: DriverService())
    @State private var showingAddSheet = false
    @State private var editingDriver: Driver?
    @State private var driverToDelete: Driver?
    @State private var showingDeleteAlert = false

    var body: some View {
        Group {
            if vm.items.isEmpty && !vm.isLoading {
                ContentUnavailableView(
                    "No Drivers",
                    systemImage: "person.text.rectangle",
                    description: Text("Pull to refresh or add data and try again.")
                )
            } else {
                List(vm.items) { driver in
                    Button {
                        editingDriver = driver
                    } label: {
                        OriginalDriverRow(
                            driver: driver,
                            onEdit: {
                                editingDriver = driver
                            },
                            onDelete: {
                                driverToDelete = driver
                                showingDeleteAlert = true
                            },
                            onShow: {
                                // Show function - can redirect to detail page
                                print("Show driver details: \(driver.fullName)")
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            driverToDelete = driver
                            showingDeleteAlert = true
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
        .navigationTitle("Drivers")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add", systemImage: "plus") {
                    showingAddSheet = true
                }
                .font(.custom("Poppins-Medium", size: 16))
            }
        }
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
        .sheet(isPresented: $showingAddSheet) {
            DriverFormView(viewModel: vm)
        }
        .sheet(item: $editingDriver) { driver in
            DriverFormView(viewModel: vm, editingDriver: driver)
        }
        .alert("Delete Driver", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let driver = driverToDelete {
                    Task {
                        await vm.delete(id: driver.id)
                    }
                }
                driverToDelete = nil
            }
        } message: {
            if let driver = driverToDelete {
                Text("Are you sure you want to delete '\(driver.fullName)'? This action cannot be undone.")
            }
        }
    }
}

private struct OriginalDriverRow: View {
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
    }
}
