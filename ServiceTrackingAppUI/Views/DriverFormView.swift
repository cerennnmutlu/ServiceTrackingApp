//
//  DriverFormView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct DriverFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DriversViewModel
    
    let editingDriver: Driver?
    
    @State private var fullName = ""
    @State private var phone = ""
    @State private var status = "Active"
    
    private let statusOptions = ["Active", "Inactive"]
    
    init(viewModel: DriversViewModel, editingDriver: Driver? = nil) {
        self.viewModel = viewModel
        self.editingDriver = editingDriver
        
        if let driver = editingDriver {
            _fullName = State(initialValue: driver.fullName)
            _phone = State(initialValue: driver.phone ?? "")
            _status = State(initialValue: driver.status ?? "Active")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Driver Information") {
                    TextField("Full Name", text: $fullName)
                        .font(.custom("Poppins-Regular", size: 16))
                    
                    TextField("Phone (Optional)", text: $phone)
                        .font(.custom("Poppins-Regular", size: 16))
                        .keyboardType(.phonePad)
                }
                
                Section("Details") {
                    Picker("Status", selection: $status) {
                        ForEach(statusOptions, id: \.self) { option in
                            Text(option)
                                .font(.custom("Poppins-Regular", size: 16))
                                .tag(option)
                        }
                    }
                    .font(.custom("Poppins-Regular", size: 16))
                }
            }
            .navigationTitle(editingDriver == nil ? "New Driver" : "Edit Driver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("Poppins-Regular", size: 16))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingDriver == nil ? "Add" : "Update") {
                        Task {
                            await saveDriver()
                        }
                    }
                    .font(.custom("Poppins-Medium", size: 16))
                    .disabled(fullName.isEmpty || viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
    }
    
    private func saveDriver() async {
        if let editingDriver = editingDriver {
            // Update
            let request = UpdateDriverRequest(
                fullName: fullName,
                phone: phone.isEmpty ? nil : phone,
                status: status
            )
            
            let success = await viewModel.update(id: editingDriver.id, request)
            if success {
                await viewModel.load() // Refresh list
                dismiss()
            }
        } else {
            // Create new
            let request = CreateDriverRequest(
                fullName: fullName,
                phone: phone.isEmpty ? nil : phone,
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
    DriverFormView(viewModel: DriversViewModel(service: DriverService()))
}