//
//  PriceRepository.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 10/9/25.
//

import Foundation

protocol PriceRepositoryProtocol {
    func getPrice(date: Date) async throws -> EsiosResponse
}

final class PriceRepository: PriceRepositoryProtocol {
    
    private let remoteDataSource: RemoteDataSourceProtocol
    
    init(remoteDataSource: RemoteDataSourceProtocol = RemoteDataSourceImpl()) {
        self.remoteDataSource = remoteDataSource
    }
    
    func getPrice(date: Date) async throws -> EsiosResponse {
        guard let response = try await remoteDataSource.getJson(date: date) else {
            throw NSError(domain: "RepositoryError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
        }
        return response
    }
}
