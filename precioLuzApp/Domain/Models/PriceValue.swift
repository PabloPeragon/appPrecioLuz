//
//  PriceValue.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 14/9/25.
//

import Foundation

struct PriceValue: Codable {
    let datetime: Date
    let value: Double //Precio en €/kWh (convertido desde MWh)
    let geoId: Int //ID de la zona geográfica
    let geoName: String //Nombre de la zona geográfica
    
    
    enum CodingKeys: String, CodingKey {
        case datetime = "datetime"
        case value = "value"
        case geoId = "geo_id"
        case geoName = "geo_name"
    }

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decodificar value y convertir de MWH a KWh (dividir por 1000)
        let rawValue = try container.decode(Double.self, forKey: .value)
        value = rawValue / 1000
        
        // Decodificar información geográfica
        geoId = try container.decode(Int.self, forKey: .geoId)
        geoName = try container.decode(String.self, forKey: .geoName)
        
        print("Conversión MWh a kWh: \(rawValue) -> \(value) [\(geoName)]")
        
        // Decodificar datetime desde String y convertir a Date
        let datetimeString = try container.decode(String.self, forKey: .datetime)
        
        // Formatters para ESIOS (API española de electricidad)
        let formatters = [
            createFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ"),  // 2024-03-15T10:00:00+01:00
            createFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ"),      // 2024-03-15T10:00:00Z
            createFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"),  // 2024-03-15T10:00:00.000Z
            createFormatter(format: "yyyy-MM-dd'T'HH:mm:ss"),       // 2024-03-15T10:00:00
        ]
        
        // Intentar parsear con cada formatter
        var parsedDate: Date?
        for formatter in formatters {
            if let date = formatter.date(from: datetimeString) {
                parsedDate = date
                print("Fecha parseada: \(datetimeString) -> \(date)")
                break
            }
        }
        
        guard let date = parsedDate else {
            print("No se pudo parsear datetime: '\(datetimeString)'")
            print("Formatos intentados:")
            for formatter in formatters {
                let format = formatter.dateFormat ?? "unknown format"
                print("   - \(format)")
            }
            
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath + [CodingKeys.datetime],
                    debugDescription: "Formato de datetime no reconocido: '\(datetimeString)'"
                )
            )
        }
        
        datetime = date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        
        // Encodear datetime como String ISO
        let formatter = createFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ")
        let dateString = formatter.string(from: datetime)
        try container.encode(dateString, forKey: .datetime)
    }
}

// MARK: - Helper para formatters
private func createFormatter(format: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.timeZone = TimeZone.current
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}
