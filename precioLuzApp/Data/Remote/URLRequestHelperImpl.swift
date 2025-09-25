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
        formatter.timeZone = TimeZone(identifier: "Europe/Madrid")
        let dateString = formatter.string(from: date)
        
        // En agosto es +02:00 (Horario de verano
        // En invierno sería +01:00
        let timeZoneOffset = TimeZone(identifier: "Europe/Madrid")?.secondsFromGMT() ?? 7200
        let offsetHours = timeZoneOffset / 3600
        let offsetString = String(format: "%+03d:00", offsetHours)
        
        
        
        components.queryItems = [
                .init(name: "start_date", value: "\(dateString)T00:00:00\(offsetString)"),
                .init(name: "end_date", value: "\(dateString)T23:59:59\(offsetString)")
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
