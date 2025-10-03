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
    @State private var now = Date()
    
    // Fecha máxima seleccionable: hasta hoy, o hasta mañana a partir de las 20:30
    private var maxSelectableDate: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let allowTomorrow = (hour > 20) || (hour == 20 && minute >= 30)

        let todayStart = calendar.startOfDay(for: now)

        if allowTomorrow {
            let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? now
            return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: tomorrowStart) ?? tomorrowStart
        } else {
            return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart) ?? todayStart
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Selector de zona geográfica
                Section("Zona Geográfica") {
                    Picker("Selecciona zona", selection: $viewModel.selectedGeoId) {
                        ForEach(Array(viewModel.geoZones.keys).sorted(), id: \.self) { id in
                            Text(viewModel.geoZones[id] ?? "Desconocida").tag(id)
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
                               in: ...maxSelectableDate,
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
                                Text("Precio Min: \(minValue.value, specifier: "%.4f")€/kWh a las \(viewModel.formatTime(minValue.datetime)) h")
                                    .foregroundColor(.green)
                            }
                            
                            if let maxValue = viewModel.mostExpensivePriceValues {
                                Text("Precio Max: \(maxValue.value, specifier: "%.4f")€/kWh a las \(viewModel.formatTime(maxValue.datetime)) h")
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
                            let isMin = viewModel.cheapestPriceValue?.datetime == item.datetime
                            let isMax = viewModel.mostExpensivePriceValues?.datetime == item.datetime
                            HStack {
                                Text(viewModel.formatTime(item.datetime))
                                    .font(.system(.body, design: .monospaced))
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(item.value, specifier: "%.4f")€/kWh")
                                        .foregroundColor(viewModel.getColorForPrice(item.value))
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight((isMin || isMax) ? .semibold : .regular)
                                    if isMin {
                                        Text("Mínimo")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    }
                                    if isMax {
                                        Text("Máximo")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                    }
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
            .task {
                while !Task.isCancelled {
                    await MainActor.run {
                        now = Date()
                        // Si la fecha seleccionada supera el máximo permitido (p.ej., antes de 20:30), la ajustamos
                        if selectedDate > maxSelectableDate {
                            let startOfAllowed = Calendar.current.startOfDay(for: maxSelectableDate)
                            selectedDate = startOfAllowed
                        }
                    }
                    try? await Task.sleep(nanoseconds: 30 * 1_000_000_000)
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

