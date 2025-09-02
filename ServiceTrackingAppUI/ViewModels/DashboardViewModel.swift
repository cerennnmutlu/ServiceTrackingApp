//
//  DashboardViewModel.swift
//  ServiceTrackingAppUI
//
//  Created by AI on 29.08.2025.
//

import Foundation

struct DashboardStats {
    let totalVehicles: Int
    let activeVehicles: Int
    let inactiveVehicles: Int
    
    let totalDrivers: Int
    let activeDrivers: Int
    let inactiveDrivers: Int
    
    let totalRoutes: Int
    let activeRoutes: Int
    let inactiveRoutes: Int
    
    let totalShifts: Int
    let morningShifts: Int
    let eveningShifts: Int
    let nightShifts: Int
}

struct TodayMovement {
    let id = UUID()
    let plateNumber: String
    let type: MovementType
    let time: String
    let shift: String
    
    enum MovementType {
        case entry
        case exit
        
        var icon: String {
            switch self {
            case .entry: return "🟢"
            case .exit: return "🔴"
            }
        }
        
        var text: String {
            switch self {
            case .entry: return "Giriş"
            case .exit: return "Çıkış"
            }
        }
    }
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var stats = DashboardStats(
        totalVehicles: 0, activeVehicles: 0, inactiveVehicles: 0,
        totalDrivers: 0, activeDrivers: 0, inactiveDrivers: 0,
        totalRoutes: 0, activeRoutes: 0, inactiveRoutes: 0,
        totalShifts: 0, morningShifts: 0, eveningShifts: 0, nightShifts: 0
    )
    
    @Published var todayMovements: [TodayMovement] = []
    @Published var weeklyData: [Int] = [12, 18, 15, 22, 19, 8, 5] // Örnek haftalık veri
    @Published var isLoading = false
    @Published var error: String?
    @Published var userName: String = "Kullanıcı"
    
    private let vehicleService: VehicleServicing
    private let driverService: DriverServicing
    private let routeService: RouteServicing
    private let shiftService: ShiftServicing
    private let authService: AuthServicing
    
    init(
        vehicleService: VehicleServicing = VehicleService(),
        driverService: DriverServicing = DriverService(),
        routeService: RouteServicing = RouteService(),
        shiftService: ShiftServicing = ShiftService(),
        authService: AuthServicing
    ) {
        self.vehicleService = vehicleService
        self.driverService = driverService
        self.routeService = routeService
        self.shiftService = shiftService
        self.authService = authService
        
        // Örnek bugünkü hareketler
        self.todayMovements = [
            TodayMovement(plateNumber: "34 ABC 123", type: .entry, time: "09:15", shift: "Sabah"),
            TodayMovement(plateNumber: "34 XYZ 789", type: .exit, time: "09:10", shift: "Sabah"),
            TodayMovement(plateNumber: "34 DEF 456", type: .entry, time: "09:05", shift: "Sabah"),
            TodayMovement(plateNumber: "06 GHI 321", type: .entry, time: "08:45", shift: "Sabah"),
            TodayMovement(plateNumber: "35 JKL 654", type: .exit, time: "08:30", shift: "Sabah")
        ]
    }
    
    func loadDashboardData() async {
        isLoading = true
        error = nil
        
        do {
            // Kullanıcı profil bilgilerini yükle
            let user = try await authService.getProfile()
            userName = user.fullName
            async let vehicles = vehicleService.list()
            async let drivers = driverService.list()
            async let routes = routeService.list()
            async let shifts = shiftService.list()
            
            let (vehicleList, driverList, routeList, shiftList) = try await (vehicles, drivers, routes, shifts)
            
            // Vehicle stats
            let totalVehicles = vehicleList.count
            let activeVehicles = vehicleList.filter { $0.status == "Active" }.count
            let inactiveVehicles = totalVehicles - activeVehicles
            
            // Driver stats
            let totalDrivers = driverList.count
            let activeDrivers = driverList.filter { $0.status == "Active" }.count
            let inactiveDrivers = totalDrivers - activeDrivers
            
            // Route stats
            let totalRoutes = routeList.count
            let activeRoutes = routeList.filter { $0.status == "Active" }.count
            let inactiveRoutes = totalRoutes - activeRoutes
            
            // Shift stats (örnek kategorilere göre)
            let totalShifts = shiftList.count
            let morningShifts = shiftList.filter { shift in
                // startTime String formatında "HH:mm:ss" olarak geliyor
                let timeComponents = shift.startTime.split(separator: ":")
                guard let hourString = timeComponents.first,
                      let hour = Int(hourString) else { return false }
                return hour >= 6 && hour < 14
            }.count
            let eveningShifts = shiftList.filter { shift in
                let timeComponents = shift.startTime.split(separator: ":")
                guard let hourString = timeComponents.first,
                      let hour = Int(hourString) else { return false }
                return hour >= 14 && hour < 22
            }.count
            let nightShifts = totalShifts - morningShifts - eveningShifts
            
            self.stats = DashboardStats(
                totalVehicles: totalVehicles,
                activeVehicles: activeVehicles,
                inactiveVehicles: inactiveVehicles,
                totalDrivers: totalDrivers,
                activeDrivers: activeDrivers,
                inactiveDrivers: inactiveDrivers,
                totalRoutes: totalRoutes,
                activeRoutes: activeRoutes,
                inactiveRoutes: inactiveRoutes,
                totalShifts: totalShifts,
                morningShifts: morningShifts,
                eveningShifts: eveningShifts,
                nightShifts: nightShifts
            )
            
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        
        isLoading = false
    }
    

    
    var activeVehiclesToday: Int {
        stats.activeVehicles
    }
}