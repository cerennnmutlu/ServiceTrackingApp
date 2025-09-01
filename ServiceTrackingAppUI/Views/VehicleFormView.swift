//
//  VehicleFormView.swift
//  ServiceTrackingAppUI
//
//  Created by AI on 29.08.2025.
//

import SwiftUI

struct VehicleFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VehiclesViewModel
    @StateObject private var routesViewModel = RoutesViewModel(service: RouteService())
    
    let editingVehicle: ServiceVehicle?
    
    @State private var plateNumber = ""
    @State private var brand = ""
    @State private var model = ""
    @State private var capacity = ""
    @State private var status = "Active"
    @State private var selectedRouteID: Int = 0
    
    private let statusOptions = ["Active", "Inactive", "Maintenance"]
    
    init(viewModel: VehiclesViewModel, editingVehicle: ServiceVehicle? = nil) {
        self.viewModel = viewModel
        self.editingVehicle = editingVehicle
        
        if let vehicle = editingVehicle {
            _plateNumber = State(initialValue: vehicle.plateNumber)
            _brand = State(initialValue: vehicle.brand ?? "")
            _model = State(initialValue: vehicle.model ?? "")
            _capacity = State(initialValue: String(vehicle.capacity))
            _status = State(initialValue: vehicle.status ?? "Active")
            _selectedRouteID = State(initialValue: vehicle.routeID)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Vehicle Information") {
                    TextField("Plate Number", text: $plateNumber)
                        .font(.custom("Poppins-Regular", size: 16))
                    
                    TextField("Brand (Optional)", text: $brand)
                        .font(.custom("Poppins-Regular", size: 16))
                    
                    TextField("Model (Optional)", text: $model)
                        .font(.custom("Poppins-Regular", size: 16))
                    
                    TextField("Capacity", text: $capacity)
                        .font(.custom("Poppins-Regular", size: 16))
                        .keyboardType(.numberPad)
                    
                    Picker("Route", selection: $selectedRouteID) {
                        Text("Select Route")
                            .font(.custom("Poppins-Regular", size: 16))
                            .tag(0)
                        
                        ForEach(routesViewModel.items, id: \.id) { route in
                            Text(route.routeName)
                                .font(.custom("Poppins-Regular", size: 16))
                                .tag(route.id)
                        }
                    }
                    .font(.custom("Poppins-Regular", size: 16))
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
            .navigationTitle(editingVehicle == nil ? "New Vehicle" : "Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("Poppins-Regular", size: 16))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingVehicle == nil ? "Add" : "Update") {
                        Task {
                            await saveVehicle()
                        }
                    }
                    .font(.custom("Poppins-Medium", size: 16))
                    .disabled(plateNumber.isEmpty || capacity.isEmpty || selectedRouteID == 0 || viewModel.isLoading)
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
            .onAppear {
                Task {
                    await routesViewModel.load()
                }
            }
        }
    }
    
    private func saveVehicle() async {
        guard let capacityInt = Int(capacity) else {
            return
        }
        
        if let editingVehicle = editingVehicle {
            // Update
            let request = UpdateVehicleRequest(
                plateNumber: plateNumber,
                brand: brand.isEmpty ? nil : brand,
                model: model.isEmpty ? nil : model,
                capacity: capacityInt,
                status: status,
                routeID: selectedRouteID
            )
            
            let success = await viewModel.update(id: editingVehicle.id, request)
            if success {
                await viewModel.load() // Refresh list
                dismiss()
            }
        } else {
            // Create new
            let request = CreateVehicleRequest(
                plateNumber: plateNumber,
                brand: brand.isEmpty ? nil : brand,
                model: model.isEmpty ? nil : model,
                capacity: capacityInt,
                status: status,
                routeID: selectedRouteID
            )
            
            let success = await viewModel.create(request)
            if success {
                await viewModel.load() // Refresh list
                dismiss()
            }
        }
    }
}

#Preview {
    VehicleFormView(viewModel: VehiclesViewModel(service: VehicleService()))
}