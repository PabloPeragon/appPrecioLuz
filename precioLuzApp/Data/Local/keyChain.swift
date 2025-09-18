//
//  keyChain.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 2/9/25.
//

import Foundation
import KeychainSwift

final class KeyChain {
    static let shared = KeyChain()
    private let keychain = KeychainSwift()
    private init() {}
    
    private let tokenKey = "esios_token"
    
    //guardar token
    func saveToken(_ token: String) {
        print("Guardando token en Keychain...")
        let success = keychain.set(token, forKey: tokenKey)
        print("Token guardado: \(success)")
        if success {
            print("🔍 Token guardado (preview): \(String(token.prefix(10)))...")
        }
    }
    
    //leer token con debug
    func getToken() -> String? {
        print("Intentando leer token del Keychain...")
        let token = keychain.get(tokenKey)
        
        if let token = token {
            print("Token encontrado (length: \(token.count))")
            print("Token preview: \(String(token.prefix(10)))...")
            return token
        } else {
            print("No se encontró token en Keychain")
            print("Verificando si la key existe...")
            
            // Verificar todas las keys disponibles (para debug)
            let allKeys = keychain.allKeys
            print("Keys disponibles en Keychain: \(allKeys)")
            
            return nil
        }
    }
    
    //borrar token
    func deleteToken() {
        print("Borrando token del Keychain...")
        let success = keychain.delete(tokenKey)
        print("Token borrado: \(success)")
    }
    
    // Método helper para verificar el estado
    func debugKeychainState() {
        print("=== KEYCHAIN DEBUG ===")
        print("Todas las keys: \(keychain.allKeys)")
        print("Token key: \(tokenKey)")
        print("Token existe: \(keychain.get(tokenKey) != nil)")
        if let token = keychain.get(tokenKey) {
            print("Token length: \(token.count)")
        }
        print("======================")
    }
}
