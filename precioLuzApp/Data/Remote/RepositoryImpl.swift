//
//  RepositoryImpl.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 8/9/25.
//

import Foundation

final class RepositoryImpl: RepositoryProtocol {
    
    //Propiedades
    var remoteDataSource: RemoteDataSourceProtocol
    
    //Inicializamos
    init(remoteDataSource: RemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }
    
    func getJson(date: Date) async throws -> EsiosResponse? {
        return try await remoteDataSource.getJson(date: date)
    }
    
}
