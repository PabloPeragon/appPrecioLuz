//
//  AppState.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 5/9/25.
//

import Foundation
import KeychainSwift

final class AppState: ObservableObject {
    @Published var hasToken: Bool
    private let keychain = KeychainSwift()
    private let tokenKey = "esios_token"
    
    init() {
        self.hasToken = keychain.get(tokenKey) != nil
        print("AppState init - hasToken: \(hasToken)")
    }
    
    func saveToken(_ token: String) {
        print("AppState: Guardando token con key '\(tokenKey)'...")
        let success = keychain.set(token, forKey: tokenKey)
        print("AppState: Token guardado - success: \(success)")
        
        // Verificar inmediatamente
        let retrieved = keychain.get(tokenKey)
        print("AppState: Token verificado - existe: \(retrieved != nil)")
        
        hasToken = retrieved != nil
        
        // Debug adicional
        if let retrieved = retrieved {
            print("AppState: Token length: \(retrieved.count)")
        }
    }
    
    func deleteToken() {
        print("AppState: Eliminando token...")
        let success = keychain.delete(tokenKey)
        print("AppState: Token eliminado - success: \(success)")
        hasToken = false
    }
    
    // Método helper para debug
    func debugState() {
        print("=== APPSTATE DEBUG ===")
        print("hasToken: \(hasToken)")
        print("tokenKey: \(tokenKey)")
        let tokenExists = keychain.get(tokenKey) != nil
        print("Token exists in keychain: \(tokenExists)")
        print("All keychain keys: \(keychain.allKeys)")
        print("========================")
    }
}
