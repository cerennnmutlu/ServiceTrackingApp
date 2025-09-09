//
//  TrackingListView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI
import Foundation

struct TrackingListView: View {
    @StateObject private var viewModel = TrackingViewModel(service: TrackingService())
    @StateObject private var shiftsViewModel = ShiftsViewModel(service: ShiftService())
    
    @State private var searchText = ""
    @State private var selectedShiftID: Int? = nil
    @State private var showEntryList = false
    @State private var selectedEntries: Set<Int> = []
    
    private var filteredItems: [Tracking] {
        var filtered = viewModel.items
        
        // Shift filtering
        if let shiftID = selectedShiftID {
            filtered = filtered.filter { $0.shiftID == shiftID }
        }
        
        // Search by license plate or vehicle ID
        if !searchText.isEmpty {
            filtered = filtered.filter { tracking in
                // Search in vehicle plate number
                let plateMatch = tracking.serviceVehicle?.plateNumber.localizedCaseInsensitiveContains(searchText) ?? false
                
                // Search in vehicle ID
                let vehicleIdMatch = String(tracking.serviceVehicleID).localizedCaseInsensitiveContains(searchText)
                
                // Search in movement type
                let movementMatch = tracking.movementType?.localizedCaseInsensitiveContains(searchText) ?? false
                
                return plateMatch || vehicleIdMatch || movementMatch
            }
        }
        
        return filtered
    }
    
    private var entryItems: [Tracking] {
        filteredItems.filter { $0.movementType?.lowercased() == "entry" }
    }
    
    var body: some View {
        VStack {
            // Search and Filter Section
            HStack(spacing: 12) {
                // Search Box
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by plate, vehicle ID or movement...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Shift Filter
                HStack {
                    Text("Shift:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Select Shift", selection: $selectedShiftID) {
                        Text("All").tag(nil as Int?)
                        ForEach(shiftsViewModel.items, id: \.id) { shift in
                            Text(shift.shiftName).tag(shift.id as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.white)
            
            // Toolbar Buttons
            HStack {
                Button(action: {
                    withAnimation {
                        showEntryList.toggle()
                        selectedEntries.removeAll()
                    }
                }) {
                    Text(showEntryList ? "All Records" : "Entry List")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                if showEntryList {
                    Button(action: {
                        if selectedEntries.count == entryItems.count {
                            selectedEntries.removeAll()
                        } else {
                            selectedEntries = Set(entryItems.map { $0.id })
                        }
                    }) {
                        Text(selectedEntries.count == entryItems.count ? "Deselect All" : "Select All")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    
                    if !selectedEntries.isEmpty {
                        Text("\(selectedEntries.count) selected")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                        
                        Button(action: {
                            Task {
                                for id in selectedEntries {
                                    let tracking = entryItems.first { $0.id == id }
                                    if let tracking = tracking {
                                        let request = UpdateTrackingRequest(
                                            serviceVehicleID: tracking.serviceVehicleID,
                                            shiftID: tracking.shiftID,
                                            trackingDateTime: tracking.trackingDateTime,
                                            movementType: "Exit"
                                        )
                                        await viewModel.update(id: id, request)
                                    }
                                }
                                selectedEntries.removeAll()
                                showEntryList = false
                            }
                        }) {
                            Text("Bulk Exit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        .disabled(selectedEntries.isEmpty)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Bugün girilen kayıt sayısı
            HStack {
                Text("Bugün Girilen Kayıt Sayısı:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.todayEntryCount)")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.white)
            
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if (showEntryList ? entryItems : filteredItems).isEmpty {
                ContentUnavailableView(
                    viewModel.items.isEmpty ? "No Tracking Records" : "No Results",
                    systemImage: viewModel.items.isEmpty ? "location.slash" : "magnifyingglass",
                    description: Text(viewModel.items.isEmpty ? "No tracking records found. Add a new tracking record to get started." : "No tracking records match your search criteria.")
                )
            } else {
                List {
                    ForEach(showEntryList ? entryItems : filteredItems, id: \.id) { tracking in
                        TrackingRowView(tracking: tracking, viewModel: viewModel, isSelected: selectedEntries.contains(tracking.id), onSelect: {
                            withAnimation {
                                if selectedEntries.contains(tracking.id) {
                                    selectedEntries.remove(tracking.id)
                                } else {
                                    selectedEntries.insert(tracking.id)
                                }
                            }
                        }, showCheckbox: showEntryList)
                            .buttonStyle(PlainButtonStyle())
                            .transition(.opacity)
                    }
                    .onDelete(perform: deleteTracking)
                }
                .listStyle(PlainListStyle())
                .animation(.default, value: showEntryList)
                .animation(.default, value: filteredItems)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await viewModel.load()
                }
            }
        }
        .background(Color.white)
        .navigationTitle("Tracking")
         .alert("Error", isPresented: .constant(viewModel.error != nil)) {
             Button("OK") {
                 viewModel.clearError()
             }
         } message: {
             Text(viewModel.error ?? "An unknown error occurred")
         }
         .onAppear {
             viewModel.loadSync()
             shiftsViewModel.loadSync()
         }
    }
    
    private func deleteTracking(offsets: IndexSet) {
        for index in offsets {
            let tracking = filteredItems[index]
            Task {
                await viewModel.delete(id: tracking.id)
            }
        }
    }
}

struct TrackingRowView: View {
    let tracking: Tracking
    let viewModel: TrackingViewModel
    let isSelected: Bool
    let onSelect: () -> Void
    let showCheckbox: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(tracking.movementType ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(tracking.trackingDateTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let vehicle = tracking.serviceVehicle {
                    Text("Vehicle: \(vehicle.plateNumber ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let shift = tracking.shift {
                    Text("Shift: \(shift.shiftName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(tracking.trackingDateTime, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if showCheckbox {
                    Button(action: onSelect) {
                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                            .foregroundColor(isSelected ? .blue : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    if tracking.movementType?.lowercased() == "entry" {
                        Button(action: {
                            Task {
                                let request = UpdateTrackingRequest(
                                    serviceVehicleID: tracking.serviceVehicleID,
                                    shiftID: tracking.shiftID,
                                    trackingDateTime: tracking.trackingDateTime,
                                    movementType: "Exit"
                                )
                                await viewModel.update(id: tracking.id, request)
                            }
                        }) {
                            Image(systemName: "arrow.right.circle")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: {
                            Task {
                                let request = UpdateTrackingRequest(
                                    serviceVehicleID: tracking.serviceVehicleID,
                                    shiftID: tracking.shiftID,
                                    trackingDateTime: tracking.trackingDateTime,
                                    movementType: "Entry"
                                )
                                await viewModel.update(id: tracking.id, request)
                            }
                        }) {
                            Image(systemName: "arrow.left.circle")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.vertical, 2)
            .background(Color.white)
        }
    }
    
}
#Preview {
        TrackingListView()
    }