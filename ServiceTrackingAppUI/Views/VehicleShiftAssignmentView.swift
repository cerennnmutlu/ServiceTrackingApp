//
//  VehicleShiftAssignmentView.swift
//  ServiceTrackingAppUI
//
//  Created by Assistant on 2024.
//

import SwiftUI
import Foundation

struct VehicleShiftAssignmentListView: View {
    @StateObject private var viewModel = VehicleShiftAssignmentViewModel(service: VehicleShiftAssignmentService())
    @State private var showingAddAssignment = false
    @State private var showingBulkAssignment = false
    @State private var showingDailyPlanning = false
    @State private var searchText = ""
    @State private var selectedDate = Date()
    @State private var selectedShiftFilter: ShiftFilter = .all
    
    enum ShiftFilter: String, CaseIterable {
        case all = "Tüm Vardiyalar"
        case morning = "Sabah"
        case daytime = "Gündüz"
        case evening = "Akşam"
        case night = "Gece-1"
        case weekend = "Hafta Sonu"
    }
    
    private var filteredItems: [VehicleShiftAssignment] {
        var filtered = viewModel.items
        
        // Filter by shift type
        if selectedShiftFilter != .all {
            filtered = filtered.filter { assignment in
                guard let shift = assignment.shift else { return false }
                let shiftName = shift.shiftName.lowercased()
                
                switch selectedShiftFilter {
                case .morning:
                    return shiftName.contains("sabah")
                case .daytime:
                    return shiftName.contains("gündüz")
                case .evening:
                    return shiftName.contains("akşam")
                case .night:
                    return shiftName.contains("gece")
                case .weekend:
                    return shiftName.contains("hafta sonu")
                default:
                    return true
                }
            }
        }
        
        // Search by vehicle plate or shift name
        if !searchText.isEmpty {
            filtered = filtered.filter { assignment in
                let vehicleMatch = assignment.serviceVehicle?.plateNumber.localizedCaseInsensitiveContains(searchText) ?? false
                let shiftMatch = assignment.shift?.shiftName.localizedCaseInsensitiveContains(searchText) ?? false
                return vehicleMatch || shiftMatch
            }
        }
        
        return filtered.sorted { assignment1, assignment2 in
            guard let shift1 = assignment1.shift, let shift2 = assignment2.shift else {
                return false
            }
            return shift1.startTime.localizedCompare(shift2.startTime) == .orderedAscending
        }
    }
    
    private var todayAssignments: [VehicleShiftAssignment] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        return viewModel.items.filter { $0.assignmentDate == todayString }
    }
    
    private var shiftStats: (total: Int, morning: Int, daytime: Int, evening: Int, night: Int, weekend: Int) {
        let total = filteredItems.count
        let morning = filteredItems.filter { 
            guard let shiftName = $0.shift?.shiftName.lowercased() else { return false }
            return shiftName.contains("sabah")
        }.count
        let daytime = filteredItems.filter { 
            guard let shiftName = $0.shift?.shiftName.lowercased() else { return false }
            return shiftName.contains("gündüz")
        }.count
        let evening = filteredItems.filter { 
            guard let shiftName = $0.shift?.shiftName.lowercased() else { return false }
            return shiftName.contains("akşam")
        }.count
        let night = filteredItems.filter { 
            guard let shiftName = $0.shift?.shiftName.lowercased() else { return false }
            return shiftName.contains("gece")
        }.count
        let weekend = filteredItems.filter { 
            guard let shiftName = $0.shift?.shiftName.lowercased() else { return false }
            return shiftName.contains("hafta sonu")
        }.count
        return (total, morning, daytime, evening, night, weekend)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Statistics Section
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    StatCard(title: "Total", value: "\(shiftStats.total)", color: .gray)
                    StatCard(title: "Sabah", value: "\(shiftStats.morning)", color: .orange)
                    StatCard(title: "Gündüz", value: "\(shiftStats.daytime)", color: .blue)
                }
                HStack(spacing: 12) {
                    StatCard(title: "Akşam", value: "\(shiftStats.evening)", color: .purple)
                    StatCard(title: "Gece-1", value: "\(shiftStats.night)", color: .indigo)
                    StatCard(title: "Hafta Sonu", value: "\(shiftStats.weekend)", color: .green)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.white)
            
            Divider()
            
            // Search and Filter Section
            VStack(spacing: 12) {
                // Search Box
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.red.opacity(0.7))
                    TextField("Search by vehicle or shift...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Filter options
                HStack {
                    // Date picker
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .tint(.red)
                    
                    Spacer()
                    
                    // Shift filter
                    Menu {
                        ForEach(ShiftFilter.allCases, id: \.self) { filter in
                            Button(filter.rawValue) {
                                selectedShiftFilter = filter
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text(selectedShiftFilter.rawValue)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
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
                    viewModel.items.isEmpty ? "No Shift Assignments" : "No Results",
                    systemImage: viewModel.items.isEmpty ? "clock.badge.minus" : "magnifyingglass",
                    description: Text(viewModel.items.isEmpty ? "No shift assignments found. Add a new assignment to get started." : "No assignments match your search criteria.")
                )
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.red.opacity(0.7))
            } else {
                List {
                    ForEach(filteredItems, id: \.id) { assignment in
                        VehicleShiftAssignmentRowView(assignment: assignment)
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
            VehicleShiftAssignmentFormView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingBulkAssignment) {
            BulkShiftAssignmentFormView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingDailyPlanning) {
            DailyShiftPlanningView(viewModel: viewModel, selectedDate: selectedDate)
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

struct VehicleShiftAssignmentRowView: View {
    let assignment: VehicleShiftAssignment
    @State private var vehiclePlateNumber: String = ""
    @State private var isLoadingVehicle = false
    
    private var isToday: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let assignmentDateObj = dateFormatter.date(from: assignment.assignmentDate) ?? Date()
        return Calendar.current.isDate(assignmentDateObj, inSameDayAs: Date())
    }
    
    private var shiftTimeInfo: String {
        if let shift = assignment.shift {
            return "\(shift.startTime) - \(shift.endTime)"
        }
        return "Time not available"
    }
    
    private var dayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let assignmentDateObj = dateFormatter.date(from: assignment.assignmentDate) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: assignmentDateObj)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with vehicle and date
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
                
                // Today indicator
                if isToday {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red.opacity(0.8))
                            .frame(width: 8, height: 8)
                        
                        Text("Today")
                            .font(.caption2)
                            .foregroundColor(.red.opacity(0.8))
                            .fontWeight(.medium)
                    }
                }
            }
            
            // Shift information
            if let shift = assignment.shift {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(shift.shiftName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .fontWeight(.medium)
                        
                        Text(shiftTimeInfo)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Date and day information
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .font(.caption2)
                        Text(assignment.assignmentDate)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.day.timeline.left")
                            .foregroundColor(.gray)
                            .font(.caption2)
                        Text(dayOfWeek)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .onAppear {
            loadVehicleInfo()
        }
    }
    
    private func loadVehicleInfo() {
        guard assignment.serviceVehicle == nil && vehiclePlateNumber.isEmpty else { return }
        
        isLoadingVehicle = true
        
        Task {
            do {
                if let vehicle = try await VehicleService().getById(id: assignment.serviceVehicleID) {
                    await MainActor.run {
                        self.vehiclePlateNumber = vehicle.plateNumber
                        self.isLoadingVehicle = false
                    }
                } else {
                    await MainActor.run {
                        self.isLoadingVehicle = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoadingVehicle = false
                }
            }
        }
    }
}

struct VehicleShiftAssignmentFormView: View {
    @ObservedObject var viewModel: VehicleShiftAssignmentViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedVehicleID = 0
    @State private var selectedShiftID = 0
    @State private var assignmentDate = Date()
    
    @StateObject private var vehiclesViewModel = VehiclesViewModel(service: VehicleService())
    @StateObject private var shiftsViewModel = ShiftsViewModel(service: ShiftService())
    
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
                    
                    Picker("Shift", selection: $selectedShiftID) {
                        Text("Select Shift").tag(0)
                        ForEach(shiftsViewModel.items, id: \.id) { shift in
                            Text(shift.shiftName).tag(shift.id)
                        }
                    }
                    
                    DatePicker("Assignment Date", selection: $assignmentDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Shift Assignment")
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
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            
                            let request = CreateVehicleShiftAssignmentRequest(
                                serviceVehicleID: selectedVehicleID,
                                shiftID: selectedShiftID,
                                assignmentDate: dateFormatter.string(from: assignmentDate)
                            )
                            
                            let success = await viewModel.create(request)
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(selectedVehicleID == 0 || selectedShiftID == 0)
                }
            }
        }
        .onAppear {
            vehiclesViewModel.loadSync()
            shiftsViewModel.loadSync()
        }
    }
}

struct DailyShiftPlanningView: View {
    @ObservedObject var viewModel: VehicleShiftAssignmentViewModel
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }
    
    private var dayAssignments: [VehicleShiftAssignment] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        return viewModel.items.filter { $0.assignmentDate == dateString }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date header
                VStack(spacing: 8) {
                    Text("Daily Shift Planning")
                        .font(.headline)
                        .foregroundColor(.red.opacity(0.8))
                    
                    Text(dateString)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                
                Divider()
                
                // Assignments list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dayAssignments.sorted { assignment1, assignment2 in
                            guard let shift1 = assignment1.shift, let shift2 = assignment2.shift else {
                                return false
                            }
                            return shift1.startTime.localizedCompare(shift2.startTime) == .orderedAscending
                        }, id: \.id) { assignment in
                            DailyShiftRowView(assignment: assignment)
                        }
                    }
                    .padding()
                }
                
                if dayAssignments.isEmpty {
                    ContentUnavailableView {
                        Label("No Shifts Planned", systemImage: "calendar.day.timeline.left")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.red.opacity(0.8))
                    } description: {
                        Text("No vehicle shifts are planned for this date.")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Shift") {
                        // Add shift action
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

struct DailyShiftRowView: View {
    let assignment: VehicleShiftAssignment
    @State private var vehiclePlateNumber: String = ""
    @State private var isLoadingVehicle = false
    
    private var timeRange: String {
        guard let shift = assignment.shift else { return "Time not available" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let startTimeString = shift.startTime
        let endTimeString = shift.endTime
        
        return "\(startTimeString) - \(endTimeString)"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(spacing: 4) {
                Text(timeRange.components(separatedBy: " - ").first ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red.opacity(0.8))
                
                Rectangle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 2, height: 30)
                
                Text(timeRange.components(separatedBy: " - ").last ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red.opacity(0.8))
            }
            
            // Assignment details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
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
                    
                    Spacer()
                    
                    if let shift = assignment.shift {
                        Text(shift.shiftName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .padding(.horizontal, 4)
        .onAppear {
            loadVehicleInfo()
        }
    }
    
    private func loadVehicleInfo() {
        guard assignment.serviceVehicle == nil && vehiclePlateNumber.isEmpty else { return }
        
        isLoadingVehicle = true
        
        Task {
            do {
                if let vehicle = try await VehicleService().getById(id: assignment.serviceVehicleID) {
                    await MainActor.run {
                        self.vehiclePlateNumber = vehicle.plateNumber
                        self.isLoadingVehicle = false
                    }
                } else {
                    await MainActor.run {
                        self.isLoadingVehicle = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoadingVehicle = false
                }
            }
        }
    }
}

struct BulkShiftAssignmentFormView: View {
    @ObservedObject var viewModel: VehicleShiftAssignmentViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedVehicleIDs: Set<Int> = []
    @State private var selectedShiftID = 0
    @State private var assignmentDate = Date()
    
    @StateObject private var vehiclesViewModel = VehiclesViewModel(service: VehicleService())
    @StateObject private var shiftsViewModel = ShiftsViewModel(service: ShiftService())
    
    var body: some View {
        NavigationView {
            Form {
                Section("Bulk Assignment Details") {
                    Picker("Shift", selection: $selectedShiftID) {
                        Text("Select Shift").tag(0)
                        ForEach(shiftsViewModel.items, id: \.id) { shift in
                            Text(shift.shiftName).tag(shift.id)
                        }
                    }
                    
                    DatePicker("Assignment Date", selection: $assignmentDate, displayedComponents: .date)
                }
                
                Section("Select Vehicles") {
                    ForEach(vehiclesViewModel.items, id: \.id) { vehicle in
                        HStack {
                            Text(vehicle.plateNumber)
                            Spacer()
                            if selectedVehicleIDs.contains(vehicle.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.red)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedVehicleIDs.contains(vehicle.id) {
                                selectedVehicleIDs.remove(vehicle.id)
                            } else {
                                selectedVehicleIDs.insert(vehicle.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bulk Assignment")
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
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            
                            let assignments = selectedVehicleIDs.map { vehicleID in
                                CreateVehicleShiftAssignmentRequest(
                                    serviceVehicleID: vehicleID,
                                    shiftID: selectedShiftID,
                                    assignmentDate: dateFormatter.string(from: assignmentDate)
                                )
                            }
                            
                            let request = CreateBulkAssignmentsRequest(assignments: assignments)
                            let success = await viewModel.createBulkAssignments(request)
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(selectedShiftID == 0 || selectedVehicleIDs.isEmpty)
                }
            }
        }
        .onAppear {
            vehiclesViewModel.loadSync()
            shiftsViewModel.loadSync()
        }
    }
}

#Preview {
    VehicleShiftAssignmentListView()
}
