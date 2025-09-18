//
//  RemoteDataSourceProtocol.swift
//  baseApp
//
//  Created by Pablo Peragón Garrido on 23/8/25.
//

import Foundation

protocol RemoteDataSourceProtocol {
    
    //Propiedades
    var urlRequestHelper: URLRequestHelperProtocol { get }
    
    //Funciones
    func getJson(date: Date) async throws -> EsiosResponse?
}

enum LoginServerError {
    case serverError
    case unknownError
}
