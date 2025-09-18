//
//  URLRequestHelperProtocol.swift
//  baseApp
//
//  Created by Pablo Peragón Garrido on 24/8/25.
//

import Foundation

protocol URLRequestHelperProtocol {
    
    //Propiedades
    var endpoints: Endpoints { get }
   
    //Funciones
    func getJson(date: Date) -> URLRequest?
}
