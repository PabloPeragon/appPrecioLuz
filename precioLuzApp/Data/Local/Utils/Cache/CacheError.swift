//
//  CacheError.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 9/9/25.
//

import Foundation

enum CacheError: Error {
    case fileNotFound
    case invalidData
    case saveFailed(Error)
    case loadFailed(Error)
}
