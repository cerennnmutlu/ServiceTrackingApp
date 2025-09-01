//
//  ShiftFormView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct ShiftFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShiftsViewModel
    
    let editingShift: Shift?
    
    @State private var shiftName = ""
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var status = "Active"
    
    private let statusOptions = ["Active", "Inactive"]
    
    init(viewModel: ShiftsViewModel, editingShift: Shift? = nil) {
        self.viewModel = viewModel
        self.editingShift = editingShift
        
        if let shift = editingShift {
            _shiftName = State(initialValue: shift.shiftName)
            _status = State(initialValue: shift.status ?? "Active")
            
            // Parse time strings to Date objects
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            
            if let start = formatter.date(from: shift.startTime) {
                _startTime = State(initialValue: start)
            }
            if let end = formatter.date(from: shift.endTime) {
                _endTime = State(initialValue: end)
            }
        } else {
            // Default times for new shift
            let calendar = Calendar.current
            let now = Date()
            _startTime = State(initialValue: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now)
            _endTime = State(initialValue: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now) ?? now)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Shift Information") {
                    TextField("Shift Name", text: $shiftName)
                        .font(.custom("Poppins-Regular", size: 16))
                }
                
                Section("Time Range") {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .font(.custom("Poppins-Regular", size: 16))
                    
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .font(.custom("Poppins-Regular", size: 16))
                }
                
                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(statusOptions, id: \.self) { option in
                            Text(option)
                                .font(.custom("Poppins-Regular", size: 16))
                                .tag(option)
                        }
                    }
                    .font(.custom("Poppins-Regular", size: 16))
                }
                
                if !shiftName.isEmpty {
                    Section("Preview") {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(shiftName)
                                    .font(.custom("Poppins-Medium", size: 16))
                                Text("\(timeString(from: startTime)) - \(timeString(from: endTime))")
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(status)
                                .font(.custom("Poppins-Regular", size: 12))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(status == "Active" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                .foregroundColor(status == "Active" ? .green : .red)
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(editingShift == nil ? "New Shift" : "Edit Shift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("Poppins-Regular", size: 16))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingShift == nil ? "Add" : "Update") {
                        Task {
                            await saveShift()
                        }
                    }
                    .font(.custom("Poppins-Medium", size: 16))
                    .disabled(shiftName.isEmpty || viewModel.isProcessing)
                }
            }
            .overlay {
                if viewModel.isProcessing {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func timeStringForAPI(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func saveShift() async {
        let startTimeString = timeStringForAPI(from: startTime)
        let endTimeString = timeStringForAPI(from: endTime)
        
        if let editingShift = editingShift {
            // Update
            let request = UpdateShiftRequest(
                shiftName: shiftName,
                startTime: startTimeString,
                endTime: endTimeString,
                status: status
            )
            
            let success = await viewModel.update(id: editingShift.id, request)
            if success {
                await viewModel.load() // Refresh list
                dismiss()
            }
        } else {
            // Create new
            let request = CreateShiftRequest(
                shiftName: shiftName,
                startTime: startTimeString,
                endTime: endTimeString,
                status: status
            )
            
            let success = await viewModel.create(request)
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    ShiftFormView(viewModel: ShiftsViewModel(service: ShiftService()))
}