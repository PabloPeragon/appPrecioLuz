//
//  CacheManagerProtocol.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 9/9/25.
//

import Foundation

protocol CacheManagerProtocol {
    func save(_ data: Data, for key: String) throws
    func load(for key: String) throws -> Data
    func remove(for key: String) throws
    func fileExists(for key: String) -> Bool
    func isDataValid(for key: String, expirationTime: TimeInterval) -> Bool
    func isDataValid(for key: String) -> Bool
    
    //Métodos especificos para ESIOS
    func saveEsiosResponse(_ response: EsiosResponse, for date: Date) throws
    func loadEsiosResponse(for date: Date) throws -> EsiosResponse
    func cacheKey(for date: Date) -> String
}
