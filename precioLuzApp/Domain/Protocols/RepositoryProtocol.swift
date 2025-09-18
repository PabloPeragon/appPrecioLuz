//
//  RepositoryProtocol.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 6/9/25.
//

import Foundation

protocol RepositoryProtocol {
    //propiedades
    var remoteDataSource: RemoteDataSourceProtocol { get }
    
    //funcion
    func getJson(date: Date) async throws -> EsiosResponse?
}
