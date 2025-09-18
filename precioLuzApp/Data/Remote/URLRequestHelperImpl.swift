//
//  URLRequestHelperImpl.swift
//  baseApp
//
//  Created by Pablo Peragón Garrido on 24/8/25.
//

import Foundation


final class URLRequestHelperImpl: URLRequestHelperProtocol {
    //propiedades
    var endpoints: Endpoints = Endpoints()
    
    
    //creacion de la base de la url para pedir los precios de la luz
    func getJson(date: Date) -> URLRequest? {
        guard var components = URLComponents(string: "\(endpoints.baseURL)/\(endpoints.indicatorID)") else {
            print("Error while creating URL from \(endpoints.baseURL)/\(endpoints.indicatorID)")
            return nil
        }
        
        //formato de fechas
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
            components.queryItems = [
            .init(name: "start_date", value: "\(dateString)T00:00:00Z"),
            .init(name: "end_date", value: "\(dateString)T23:59:59Z")
        ]
        
        guard let url = components.url else {
            print("Error while creating components url")
            return nil
        }
        
        //crear el resquest
        var urlResquest = URLRequest(url: url)
        urlResquest.httpMethod = "GET"
        urlResquest.setValue("application/json; application/vnd.esios-api-v1+json", forHTTPHeaderField: "Accept")
        urlResquest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //token seguro desde keychain
        print("obteniendo token para API resquest...")
        
        guard let token = KeyChain.shared.getToken() else {
            print("Error getting token")
            
            //para debug
            KeyChain.shared.debugKeychainState()
            return nil
        }
        
        //verificar queel token no esté vacio
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty else {
            print("Error: El token esta vacio")
            return nil
        }
        
        urlResquest.setValue(token, forHTTPHeaderField: "x-api-key")
        return urlResquest
    }
}
    
