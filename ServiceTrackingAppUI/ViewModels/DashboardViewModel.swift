//
//  DashboardViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import Foundation
import SwiftUI

// MARK: - Dashboard Stats Model
struct DashboardStats {
    var activeVehicles: Int = 0
    var activeDrivers: Int = 0
}

class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var stats: DashboardStats = DashboardStats()
    @Published var weeklyData: [Int] = [0, 0, 0, 0, 0, 0, 0] // Mon-Sun
    @Published var userName: String = "Kullanıcı"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Services
    private let trackingService: TrackingServicing
    private let authService: AuthServicing
    private let vehicleService: VehicleServicing
    private let driverService: DriverServicing
    
    // MARK: - Initialization
    init(trackingService: TrackingServicing, authService: AuthServicing,
         vehicleService: VehicleServicing = VehicleService(),
         driverService: DriverServicing = DriverService()) {
        self.trackingService = trackingService
        self.authService = authService
        self.vehicleService = vehicleService
        self.driverService = driverService
    }
    
    // MARK: - Data Loading
    @MainActor
    func loadDashboardData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load user profile for welcome message
            await loadUserProfile()
            
            // Load vehicle and driver stats
            await loadVehicleAndDriverStats()
            
            // Generate sample weekly data
            generateSampleWeeklyData()
            
            isLoading = false
        } catch {
            errorMessage = "Veri yüklenirken bir hata oluştu: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Helper Methods
    @MainActor
    private func loadUserProfile() async {
        do {
            let user = try await authService.getProfile()
            userName = user.fullName
        } catch {
            print("Kullanıcı profili yüklenemedi: \(error.localizedDescription)")
            // Hata durumunda varsayılan isim kullanılır
        }
    }
    
    @MainActor
    private func loadVehicleAndDriverStats() async {
        do {
            // Tüm araçları ve sürücüleri al
            let vehicles = try await vehicleService.list()
            let drivers = try await driverService.list()
            
            // Status değeri "active" olan araçları filtrele
            let activeVehicles = vehicles.filter { $0.status?.lowercased() == "active" }
            
            // Status değeri "active" olan sürücüleri filtrele
            let activeDrivers = drivers.filter { $0.status?.lowercased() == "active" }
            
            // İstatistikleri güncelle
            stats.activeVehicles = activeVehicles.count
            stats.activeDrivers = activeDrivers.count
            
        } catch {
            print("Araç ve sürücü istatistikleri yüklenemedi: \(error.localizedDescription)")
            // Hata durumunda varsayılan değerler kullanılır
        }
    }
    
    private func generateSampleWeeklyData() {
        // Örnek haftalık araç hareketleri verileri
        weeklyData = [12, 19, 15, 22, 18, 10, 8]
    }
}
