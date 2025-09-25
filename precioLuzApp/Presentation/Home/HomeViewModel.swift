//
//  HomeViewModel.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 10/9/25.
//

import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    
    //MARK: - Properties
    private let repository: PriceRepositoryProtocol
    
    //MARK: Published Properties
    @Published var esiosResponse: EsiosResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedGeoId: Int = 8741 // Por defecto Peninsula
    
    // Mapeo de IDs geográficos
    let geoZones: [Int: String] = [
        8741: "Península",
        8742: "Canarias",
        8743: "Baleares",
        8744: "Ceuta",
        8745: "Melilla",
    ]
    
    //MARK: - Init
    init(repository: PriceRepositoryProtocol = PriceRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    func fetchPrices(for date: Date = Date()) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await repository.getPrice(date: date)
            self.esiosResponse = result
            self.isLoading = false
            
            // Debug: mostrar todas las zonas disponibles
            let uniqueZones = Set(result.indicator.values.map { "\($0.geoId): \($0.geoName)" })
            print("Zonas disponibles: \(uniqueZones)")
            print("Datos cargados: \(result.indicator.values.count) precios totales")
            print("Filtrado para zona \(selectedGeoId): \(filteredPrices.count) precios")
            
        } catch {
            self.isLoading = false
            self.errorMessage = getErrorMessage(error)
            print("Error: \(error)")
        }
    }
    
    
    func loadPrices(for date: Date = Date()) {
        Task {
            await fetchPrices(for: date)
        }
    }
    
    // Función para cambiar la zona seleccionada
    func selectGeoZone(_ geoId: Int) {
        selectedGeoId = geoId
        print("Zona cambiada a: \(geoZones[geoId] ?? "Desconocida") (ID: \(geoId))")
    }
    
    // MARK: - Computed Properties
    
    //Solo precios de la zona seleccionada
    var filteredPrices: [PriceValue] {
        let allPrices = esiosResponse?.indicator.values ?? []
        return allPrices.filter { $0.geoId == selectedGeoId }
        }
    

    var prices: [PriceValue] {
        return filteredPrices
    }
    
    var hasData: Bool {
        !filteredPrices.isEmpty
    }
    
    var cheapestPriceValue: PriceValue? {
        filteredPrices.min(by: { $0.value < $1.value})
    }
    
    var mostExpensivePriceValues: PriceValue? {
        filteredPrices.max(by: { $0.value < $1.value})
    }
    
    var avergarePrice: Double? {
        guard !filteredPrices.isEmpty else { return nil }
        let total = filteredPrices.reduce(0) { $0 + $1.value }
        return total / Double(filteredPrices.count)
    }
    
    func currentHourPrice(_ date: Date) -> PriceValue? {
        let calendar = Calendar.current
        let selectedHour = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        
        return filteredPrices.first { value in
            let comps = calendar.dateComponents([.year, .month, .day, .hour], from: value.datetime)
            return comps == selectedHour
        }
    }
    
    // MARK: - Helper Methods
    
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func getColorForPrice(_ price: Double) -> Color {
        switch price {
        case ..<0.10: return .green
        case 0.10..<0.15: return .orange
        default: return .red
        }
    }
    
    
    private func getErrorMessage(_ error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No hay conexión a internet"
            case .timedOut:
                return "Tiempo de espera agotado"
            default:
                return "Error de red"
            }
        }
        return "Error al cargar los datos"
    }
}
