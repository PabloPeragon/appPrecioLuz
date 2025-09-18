//
//  CacheManager.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 9/9/25.
//

import Foundation

final class CacheManager: CacheManagerProtocol {
    
    // MARK: - Singleton
    static let shared = CacheManager()
    private init() {}
    
    //MARK: - Properties
    private let fileManager = FileManager.default
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    
    // Directorio de documentos de la app
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    //MARK: - Public Methos
    
    ///Genera una clave única para la fecha
    func cacheKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "esios_\(formatter.string(from: date))"
    }
    
    /// Guarda datos en cache
    func save(_ data: Data, for key: String) throws {
        let fileURL = documentsDirectory.appendingPathComponent(key)
        
        do {
            try data.write(to: fileURL, options: [.atomic])
            print("Cache guardado: \(fileURL.lastPathComponent)")
        } catch {
            print("Error guardando cache: \(error)")
            throw CacheError.saveFailed(error)
        }
    }
    
    /// Carga datos desde el cache
    func load(for key: String) throws -> Data {
        let fileURL = documentsDirectory.appendingPathComponent(key)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw CacheError.fileNotFound
        }
        
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("Error cargando cache: \(error)")
            throw CacheError.loadFailed(error)
        }
    }
    
    /// Elimina un archivo de cache
    func remove(for key: String) throws {
        let fileURL = documentsDirectory.appendingPathComponent(key)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return //No existe, no hay que hacer nada
        }
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("Cache eliminado: \(key)")
        } catch {
            print("Error eliminando cache: \(error)")
            throw error
        }
    }
    
    /// Verifica si un archivo existe
    func fileExists(for key: String) -> Bool {
        let fileURL = documentsDirectory.appendingPathComponent(key)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Verifica si los datos son válidos (no han expirado)
    func isDataValid(for key: String, expirationTime: TimeInterval) -> Bool {
        let fileURL = documentsDirectory.appendingPathComponent(key)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let modificationDate = attributes[.modificationDate] as? Date {
                let timeSinceModification = Date().timeIntervalSince(modificationDate)
                return timeSinceModification < expirationTime
            }
        } catch {
            print("Error verificando validez: \(error)")
        }
        return false
    }
    
    // Método conveniencia con valor por defecto
    func isDataValid(for key: String) -> Bool {
        return isDataValid(for: key, expirationTime: 86400)
    }
    
    // MARK: - Métodos
    
    /// Guarda la respuesta de ESIOS
    func saveEsiosResponse(_ response: EsiosResponse, for date: Date) throws {
        let key = cacheKey(for: date)
        let data = try jsonEncoder.encode(response)
        try save(data, for: key)
    }
    
    /// Carga la respuesta de ESIOS
    func loadEsiosResponse(for date: Date) throws -> EsiosResponse {
            let key = cacheKey(for: date)
            let data = try load(for: key)
            return try jsonDecoder.decode(EsiosResponse.self, from: data)
        }
}
