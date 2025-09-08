//
//  VehicleAssignmentView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct VehicleAssignmentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern Tab Selector
            VStack(spacing: 0) {
                Picker("Assignment Type", selection: $selectedTab) {
                    Text("Driver Assignment").tag(0)
                    Text("Shift Assignment").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
            .background(Color.white)
            
            // Content Area
            if selectedTab == 0 {
                
                VehicleDriverAssignmentListView()
                    .navigationTitle("Driver Assignment")
            } else {
               
                VehicleShiftAssignmentListView()
                    .navigationTitle("Shift Assignment")
            }
        }
        .background(Color.white)
        
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    VehicleAssignmentView()
}
