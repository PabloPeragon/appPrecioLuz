//
//  EsiosResponse.swift
//  baseApp
//
//  Created by Pablo Peragón Garrido on 23/8/25.
//

import Foundation

struct EsiosResponse: Decodable, Encodable {
    let indicator: Indicator
}

struct Indicator: Decodable, Encodable {
    let id: Int
    let name: String
    let shortName: String
    let values: [PriceValue]
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case shortName = "short_name"
        case values
    }
}
