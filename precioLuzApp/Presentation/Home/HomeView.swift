//
//  HomeView.swift
//  baseApp
//
//  Created by Pablo Peragón Garrido on 21/8/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedDate = Date()
    
    /// The main content view for the Home screen.
    ///
    /// This computed property builds a `NavigationView` containing a `Form` with several sections:
    /// - A geographic zone selector (`Picker`) bound to `viewModel.selectedGeoId`. Changing the selection
    ///   triggers a reload of price data for the currently selected date.
    /// - A date selector (`DatePicker`) limited to dates up to today, localized to Spanish (`es_ES`).
    ///   Changing the date triggers a reload of price data for that date.
    /// - A loading state section that shows a `ProgressView` while data is being fetched.
    /// - An error section that displays any error messages reported by the `viewModel`.
    /// - A "Precio Actual" section showing the current hour's price for the selected date and zone,
    ///   or a placeholder message if unavailable.
    /// - A "Estadísticas del Día" section with minimum, maximum, and average price statistics,
    ///   shown only when data exists.
    /// - A "Precios por Horas" section listing hourly prices for the selected zone, with time formatted
    ///   monospaced and price color-coded by value.
    ///
    /// Additional behaviors:
    /// - The navigation title is set to "Precio de la Luz" and displayed inline.
    /// - Pull-to-refresh triggers an async fetch for the selected date.
    /// - On first appearance, if there are no prices loaded, the view initiates a load for the selected date.
    ///
    /// Dependencies:
    /// - Uses `HomeViewModel` as a `@StateObject` for data loading, formatting, and state management.
    /// - Relies on helper methods from the view model such as `loadPrices(for:)`, `fetchPrices(for:)`,
    ///   `currentHourPrice(_:)`, `formatTime(_:)`, and `getColorForPrice(_:)`.
    ///
    /// - Returns: A SwiftUI view hierarchy representing the Home screen UI.
    var body: some View {
        NavigationView {
            Form {
                // Selector de zona geográfica
                Section("Zona Geográfica") {
                    Picker("Selecciona zona", selection: $viewModel.selectedGeoId) {
                        ForEach(viewModel.geoZones.sorted(by: { $0.key < $1.key }), id: \.key) { id, name in
                            Text(name).tag(id)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.selectedGeoId) {
                        // Recargar datos cuando cambie la zona
                        viewModel.loadPrices(for: selectedDate)
                    }
                }
                
                // Selector de fecha
                Section("Fecha") {
                    DatePicker("Fecha:",
                               selection: $selectedDate,
                               in: ...Date(),
                               displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: "es_ES"))
                    .onChange(of: selectedDate) {
                        viewModel.loadPrices(for: selectedDate)
                    }
                }
                
                // Estado de carga
                if viewModel.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Cargando...")
                            Spacer()
                        }
                    }
                }
                
                // Error
                if let error = viewModel.errorMessage {
                    Section {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    }
                }
                
                // Precio hora actual
                Section("Precio Actual") {
                    if let current = viewModel.currentHourPrice(selectedDate) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Precio hora actual: \(current.value, specifier: "%.4f")€/kWh")
                                .foregroundColor(.brown)
                                .font(.headline)
                            Text("Zona: \(viewModel.geoZones[current.geoId] ?? "Desconocida")")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    } else {
                        Text("No hay precio para esta hora")
                            .foregroundColor(.gray)
                    }
                }
                
                // Estadísticas
                if viewModel.hasData {
                    Section("Estadísticas del Día") {
                        VStack(alignment: .leading, spacing: 8) {
                            if let minValue = viewModel.cheapestPriceValue {
                                Text("Precio Mínimo: \(minValue.value, specifier: "%.4f")€/kWh")
                                    .foregroundColor(.green)
                            }
                            
                            if let maxValue = viewModel.mostExpensivePriceValues {
                                Text("Precio Máximo: \(maxValue.value, specifier: "%.4f")€/kWh")
                                    .foregroundColor(.red)
                            }
                            
                            if let average = viewModel.avergarePrice {
                                Text("Precio medio: \(average, specifier: "%.4f")€/kWh")
                                    .foregroundColor(.blue)
                            }
                            
                            // Mostrar zona seleccionada
                            Text("Zona: \(viewModel.geoZones[viewModel.selectedGeoId] ?? "Desconocida")")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    // Lista de precios por horas (solo zona seleccionada)
                    Section("Precios por Horas - \(viewModel.geoZones[viewModel.selectedGeoId] ?? "Zona Desconocida")") {
                        ForEach(viewModel.prices, id: \.datetime) { item in
                            HStack {
                                Text(viewModel.formatTime(item.datetime))
                                    .font(.monospaced(.body)())
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(item.value, specifier: "%.4f")€/kWh")
                                        .foregroundColor(viewModel.getColorForPrice(item.value))
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Precio de la Luz")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                Task {
                    await viewModel.fetchPrices(for: selectedDate)
                }
            }
            .onAppear {
                if viewModel.prices.isEmpty {
                    viewModel.loadPrices(for: selectedDate)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
