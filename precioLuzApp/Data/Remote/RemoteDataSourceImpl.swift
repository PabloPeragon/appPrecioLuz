//
//  RemoteDataSourceImpl.swift
//  baseApp
//
//  Created by Pablo Peragón Garrido on 23/8/25.
//

import Foundation

final class RemoteDataSourceImpl: RemoteDataSourceProtocol {
    
    // MARK: - Properties
    var urlRequestHelper: URLRequestHelperProtocol = URLRequestHelperImpl()
    private let cacheManager: CacheManagerProtocol = CacheManager.shared
    
    // MARK: - Public Method
    
    func getJson(date: Date) async throws -> EsiosResponse? {
        let cacheKey = CacheManager.shared.cacheKey(for: date)
        
        // 1. Primero verificar cache válido (datos de menos de 24 horas)
        if cacheManager.isDataValid(for: cacheKey) {
            do {
                print("Cargando desde cache...")
                return try CacheManager.shared.loadEsiosResponse(for: date)
            } catch {
                print("Error cargando cache, continuando con API...")
                // Continuamos con la llamada a API
            }
        }
        
        // 2. Si no hay cache válido, llamar a la API
        guard let URLRequest = urlRequestHelper.getJson(date: date) else {
            print("Error creando URLRequest")
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Error en response")
            throw URLError(.badServerResponse)
        }
        
        switch httpResponse.statusCode {
        case 200:
            let json = try JSONDecoder().decode(EsiosResponse.self, from: data)
            
            // 3. Guardar en cache para futuro uso
            do {
                try cacheManager.saveEsiosResponse(json, for: date)  // ← Ahora está en el protocolo
                print("Datos guardados en cache")
            } catch {
                print("Error guardando en cache: \(error)")
                // No lanzamos error porque igual tenemos los datos
            }
            
            return json
            
        case 400:
            print("Bad request")
            throw URLError(.badURL)
            
        case 401:
            print("Unauthorized")
            throw URLError(.userAuthenticationRequired)
            
        case 500:
            print("Server error")
            throw URLError(.badServerResponse)
            
        default:
            print("Unknown error: \(httpResponse.statusCode)")
            throw URLError(.unknown)
        }
    }
}
