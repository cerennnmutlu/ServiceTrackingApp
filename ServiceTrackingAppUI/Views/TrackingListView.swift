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
            } else if filteredItems.isEmpty {
                ContentUnavailableView(
                    viewModel.items.isEmpty ? "No Tracking Records" : "No Results",
                    systemImage: viewModel.items.isEmpty ? "location.slash" : "magnifyingglass",
                    description: Text(viewModel.items.isEmpty ? "No tracking records found. Add a new tracking record to get started." : "No tracking records match your search criteria.")
                )
            } else {
                List {
                    ForEach(filteredItems, id: \.id) { tracking in
                        TrackingRowView(tracking: tracking, viewModel: viewModel)
                            .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete(perform: deleteTracking)
                }
                .listStyle(PlainListStyle())
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
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                
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
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 2)
        .background(Color.white)
    }
}



#Preview {
    TrackingListView()
}