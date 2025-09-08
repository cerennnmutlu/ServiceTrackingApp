//
//  ShiftDetailView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct ShiftDetailView: View {
    let shift: Shift
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(shift.shiftName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("\(shift.startTime) - \(shift.endTime)")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        // Status Badge
                        HStack {
                            Circle()
                                .fill(shift.isActive ? Color.green : Color.orange)
                                .frame(width: 12, height: 12)
                            
                            Text(shift.status ?? "Unknown")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(shift.isActive ? .green : .orange)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Shift Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Vardiya Bilgileri")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            InfoRow(title: "Vardiya ID", value: "\(shift.id)")
                            InfoRow(title: "Başlangıç Saati", value: shift.startTime)
                            InfoRow(title: "Bitiş Saati", value: shift.endTime)
                            InfoRow(title: "Durum", value: shift.status ?? "Bilinmiyor")
                            
                            if let createdAt = shift.createdAt {
                                InfoRow(title: "Oluşturulma Tarihi", value: DateFormatter.displayFormatter.string(from: createdAt))
                            }
                            
                            if let updatedAt = shift.updatedAt {
                                InfoRow(title: "Son Güncelleme", value: DateFormatter.displayFormatter.string(from: updatedAt))
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Vardiya Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

extension DateFormatter {
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
}

#Preview {
    let sampleShift = Shift(
        id: 1,
        shiftName: "Sabah Vardiyası",
        startTime: "08:00:00",
        endTime: "16:00:00",
        status: "active",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    ShiftDetailView(shift: sampleShift)
}