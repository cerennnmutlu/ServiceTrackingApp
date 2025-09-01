//
//  RouteFormView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct RouteFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RoutesViewModel
    
    let editingRoute: RouteModel?
    
    @State private var routeName = ""
    @State private var description = ""
    @State private var distance = ""
    @State private var estimatedDuration = ""
    @State private var status = "Active"
    
    private let statusOptions = ["Active", "Inactive"]
    
    init(viewModel: RoutesViewModel, editingRoute: RouteModel? = nil) {
        self.viewModel = viewModel
        self.editingRoute = editingRoute
        
        if let route = editingRoute {
            _routeName = State(initialValue: route.routeName)
            _description = State(initialValue: route.description ?? "")
            _distance = State(initialValue: route.distance?.description ?? "")
            _estimatedDuration = State(initialValue: route.estimatedDuration?.description ?? "")
            _status = State(initialValue: route.status ?? "Active")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Güzergah Bilgileri") {
                    TextField("Güzergah Adı", text: $routeName)
                        .font(.custom("Poppins-Regular", size: 16))
                    
                    TextField("Açıklama (Opsiyonel)", text: $description, axis: .vertical)
                        .font(.custom("Poppins-Regular", size: 16))
                        .lineLimit(3...6)
                }
                
                Section("Detaylar") {
                    HStack {
                        Text("Mesafe (km)")
                            .font(.custom("Poppins-Regular", size: 16))
                        Spacer()
                        TextField("0.0", text: $distance)
                            .font(.custom("Poppins-Regular", size: 16))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Tahmini Süre (dk)")
                            .font(.custom("Poppins-Regular", size: 16))
                        Spacer()
                        TextField("0", text: $estimatedDuration)
                            .font(.custom("Poppins-Regular", size: 16))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Durum", selection: $status) {
                        ForEach(statusOptions, id: \.self) { option in
                            Text(option)
                                .font(.custom("Poppins-Regular", size: 16))
                                .tag(option)
                        }
                    }
                    .font(.custom("Poppins-Regular", size: 16))
                }
            }
            .navigationTitle(editingRoute == nil ? "Yeni Güzergah" : "Güzergah Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                    .font(.custom("Poppins-Regular", size: 16))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingRoute == nil ? "Ekle" : "Güncelle") {
                        Task {
                            await saveRoute()
                        }
                    }
                    .font(.custom("Poppins-Medium", size: 16))
                    .disabled(routeName.isEmpty || viewModel.isProcessing)
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
    
    private func saveRoute() async {
        let distanceValue = Double(distance.isEmpty ? "0" : distance)
        let durationValue = Int(estimatedDuration.isEmpty ? "0" : estimatedDuration)
        
        if let editingRoute = editingRoute {
            // Güncelleme
            let request = UpdateRouteRequest(
                routeName: routeName,
                description: description.isEmpty ? nil : description,
                distance: distanceValue,
                estimatedDuration: durationValue,
                status: status
            )
            
            let success = await viewModel.update(id: editingRoute.id, request)
            if success {
                dismiss()
            }
        } else {
            // Yeni ekleme
            let request = CreateRouteRequest(
                routeName: routeName,
                description: description.isEmpty ? nil : description,
                distance: distanceValue,
                estimatedDuration: durationValue,
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
    RouteFormView(viewModel: RoutesViewModel(service: RouteService()))
}