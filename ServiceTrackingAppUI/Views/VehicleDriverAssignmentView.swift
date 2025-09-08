//
//  VehicleDriverAssignmentView.swift
//  ServiceTrackingAppUI
//
//  Created by Assistant on 2024.
//

import SwiftUI

enum TimeFilter: String, CaseIterable {
    case all = "All Time"
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
}

struct VehicleDriverAssignmentListView: View {
    @StateObject private var viewModel = VehicleDriverAssignmentViewModel(service: VehicleDriverAssignmentService())
    @State private var showingAddAssignment = false
    @State private var searchText = ""
    @State private var filterByActive = false
    @State private var selectedTimeFilter: TimeFilter = .lastMonth
    
    private var filteredItems: [VehicleDriverAssignment] {
        var filtered = viewModel.items
        
        // Filter by time period
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeFilter {
        case .today:
            filtered = filtered.filter { calendar.isDate($0.startDate, inSameDayAs: now) }
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            filtered = filtered.filter { $0.startDate >= startOfWeek }
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            filtered = filtered.filter { $0.startDate >= startOfMonth }
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            let startOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.start ?? now
            let endOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.end ?? now
            filtered = filtered.filter { $0.startDate >= startOfLastMonth && $0.startDate < endOfLastMonth }
        case .all:
            break // No time filtering
        }
        
        // Filter by active status if enabled
        if filterByActive {
            filtered = filtered.filter { $0.endDate == nil }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { assignment in
                let vehicleMatch = assignment.serviceVehicle?.plateNumber.localizedCaseInsensitiveContains(searchText) ?? false
                let driverMatch = assignment.driver?.fullName.localizedCaseInsensitiveContains(searchText) ?? false
                return vehicleMatch || driverMatch
            }
        }
        
        return filtered.sorted { $0.startDate > $1.startDate }
    }
    
    
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats Cards
            HStack(spacing: 20) {
                StatCard(title: "Total", value: "\(viewModel.items.count)", color: .gray)
                StatCard(title: "Active", value: "\(viewModel.items.filter { $0.endDate == nil }.count)", color: .red)
                StatCard(title: "Completed", value: "\(viewModel.items.filter { $0.endDate != nil }.count)", color: .green)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.white)
            
            Divider()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.red.opacity(0.7))
                TextField("Search by vehicle or driver...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.white)
            
            // Filter controls
            HStack {
                Menu {
                    ForEach(TimeFilter.allCases, id: \.self) { filter in
                        Button(filter.rawValue) {
                            selectedTimeFilter = filter
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text(selectedTimeFilter.rawValue)
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Text("Active only")
                    .foregroundColor(.gray)
                
                Toggle("", isOn: $filterByActive)
                    .toggleStyle(SwitchToggleStyle(tint: .red))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.white)
            
            Divider()
            
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredItems.isEmpty {
                ContentUnavailableView(
                    "No Driver Assignments",
                    systemImage: "person.badge.minus",
                    description: Text("No driver assignments found. Add a new assignment to get started.")
                )
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.red.opacity(0.7))
            } else {
                List {
                    ForEach(filteredItems, id: \.id) { assignment in
                        VehicleDriverAssignmentRowView(assignment: assignment)
                    }
                    .onDelete(perform: deleteAssignment)
                }
                .refreshable {
                    await viewModel.load()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddAssignment = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showingAddAssignment) {
            VehicleDriverAssignmentFormView(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.error ?? "")
        }
        .onAppear {
            viewModel.loadSync()
        }
    }
    
    private func deleteAssignment(offsets: IndexSet) {
        for index in offsets {
            let assignment = filteredItems[index]
            Task {
                await viewModel.delete(id: assignment.id)
            }
        }
    }
    
}
struct VehicleDriverAssignmentRowView: View {
    let assignment: VehicleDriverAssignment
    @State private var vehiclePlateNumber: String = ""
    @State private var isLoadingVehicle = false
    
    private var assignmentDuration: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        if let endDate = assignment.endDate {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: assignment.startDate, to: endDate)
            let days = components.day ?? 0
            return "\(days) days"
        } else {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: assignment.startDate, to: Date())
            let days = components.day ?? 0
            return "\(days) days (ongoing)"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with vehicle and status
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .foregroundColor(.red.opacity(0.7))
                        .font(.caption)
                    
                    if let vehicle = assignment.serviceVehicle {
                        Text(vehicle.plateNumber)
                            .font(.headline)
                            .foregroundColor(.red.opacity(0.8))
                    } else if !vehiclePlateNumber.isEmpty {
                        Text(vehiclePlateNumber)
                            .font(.headline)
                            .foregroundColor(.red.opacity(0.8))
                    } else if isLoadingVehicle {
                        Text("Loading...")
                            .font(.headline)
                            .foregroundColor(.red.opacity(0.8))
                    } else {
                        Text("Araç #\(assignment.serviceVehicleID)")
                            .font(.headline)
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Status badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(assignment.endDate == nil ? Color.red.opacity(0.8) : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(assignment.endDate == nil ? "Active" : "Completed")
                        .font(.caption2)
                        .foregroundColor(assignment.endDate == nil ? .red.opacity(0.8) : .gray)
                }
            }
            
            // Driver information
            if let driver = assignment.driver {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Text(driver.fullName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Assignment details
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .font(.caption2)
                        Text("Start: \(assignment.startDate, style: .date)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    if let endDate = assignment.endDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.checkmark")
                                .foregroundColor(.gray)
                                .font(.caption2)
                            Text("End: \(endDate, style: .date)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // Duration
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                            .font(.caption2)
                        Text(assignmentDuration)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .onAppear {
            if assignment.serviceVehicle == nil && vehiclePlateNumber.isEmpty {
                loadVehicleInfo()
            }
        }
    }
    
    private func loadVehicleInfo() {
        let vehicleID = assignment.serviceVehicleID
        
        isLoadingVehicle = true
        Task {
            do {
                let vehicleService = VehicleService()
                if let vehicle = try await vehicleService.getById(id: vehicleID) {
                    await MainActor.run {
                        vehiclePlateNumber = vehicle.plateNumber
                        isLoadingVehicle = false
                    }
                } else {
                    await MainActor.run {
                        isLoadingVehicle = false
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingVehicle = false
                }
            }
        }
    }
}

struct VehicleDriverAssignmentFormView: View {
    @ObservedObject var viewModel: VehicleDriverAssignmentViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedVehicleID = 0
    @State private var selectedDriverID = 0
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var hasEndDate = false
    
    @StateObject private var vehiclesViewModel = VehiclesViewModel(service: VehicleService())
    @StateObject private var driversViewModel = DriversViewModel(service: DriverService())
    
    var body: some View {
        NavigationView {
            Form {
                Section("Assignment Details") {
                    Picker("Vehicle", selection: $selectedVehicleID) {
                        Text("Select Vehicle").tag(0)
                        ForEach(vehiclesViewModel.items, id: \.id) { vehicle in
                            Text(vehicle.plateNumber).tag(vehicle.id)
                        }
                    }
                    
                    Picker("Driver", selection: $selectedDriverID) {
                        Text("Select Driver").tag(0)
                        ForEach(driversViewModel.items, id: \.id) { driver in
                            Text(driver.fullName).tag(driver.id)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("Has End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let request = CreateVehicleDriverAssignmentRequest(
                                serviceVehicleID: selectedVehicleID,
                                driverID: selectedDriverID,
                                startDate: startDate,
                                endDate: hasEndDate ? endDate : nil
                            )
                            
                            let success = await viewModel.create(request)
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(selectedVehicleID == 0 || selectedDriverID == 0)
                }
            }
        }
        .onAppear {
            vehiclesViewModel.loadSync()
            driversViewModel.loadSync()
        }
    }
    
}
#Preview {
    VehicleDriverAssignmentListView()
}
