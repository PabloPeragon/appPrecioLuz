//
//  TokenSetupView.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 5/9/25.
//

import SwiftUI
import KeychainSwift

struct TokenSetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var token: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertType: AlertType = .error
    
    enum AlertType {
        case success, error
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Configuración de Token")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Introduce tu token de ESIOS para acceder a los datos de precios")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 15) {
                TextField("Introduce tu token aquí", text: $token)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                // Preview del token (solo primeros/últimos caracteres)
                if !token.isEmpty {
                    Text("Preview: \(tokenPreview)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 10) {
                Button(action: saveToken) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isLoading ? "Guardando..." : "Guardar Token")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                
                // Botón de debug para verificar estado
                Button("Debug Keychain") {
                    debugKeychain()
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }
            
            // Info adicional
            VStack(alignment: .leading, spacing: 5) {
                Text("Información:")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("El token se guarda de forma segura en el Keychain")
                Text("Puedes obtener tu token en: esios.ree.es")
                Text("El token debe tener formato: [caracteres-alfanuméricos]")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .alert("Resultado", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Computed Properties
    private var tokenPreview: String {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 8 else { return trimmed }
        let start = String(trimmed.prefix(4))
        let end = String(trimmed.suffix(4))
        return "\(start)...\(end)"
    }
    
    // MARK: - Methods
    private func saveToken() {
        isLoading = true
        
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validación básica
        guard !trimmedToken.isEmpty else {
            showError("El token no puede estar vacío")
            return
        }
        
        guard trimmedToken.count > 10 else {
            showError("El token parece demasiado corto")
            return
        }
        
        // Guardar usando AppState
        print("Intentando guardar token vía AppState...")
        appState.saveToken(trimmedToken)
        
        // Verificar que se guardó correctamente
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            verifyTokenSaved(trimmedToken)
        }
    }
    
    private func verifyTokenSaved(_ originalToken: String) {
        // Verificar directamente en el Keychain
        let savedToken = KeyChain.shared.getToken()
        
        if let savedToken = savedToken, savedToken == originalToken {
            showSuccess("Token guardado correctamente")
            // Limpiar el campo
            token = ""
        } else {
            showError("Error al guardar el token. Intenta de nuevo.")
            print("Token verification failed:")
            print("Original: \(String(originalToken.prefix(10)))...")
            print("Saved: \(savedToken ?? "nil")")
        }
        
        isLoading = false
    }
    
    private func showSuccess(_ message: String) {
        alertType = .success
        alertMessage = message
        showAlert = true
    }
    
    private func showError(_ message: String) {
        alertType = .error
        alertMessage = message
        showAlert = true
        isLoading = false
    }
    
    private func debugKeychain() {
        print("=== TOKEN SETUP DEBUG ===")
        KeyChain.shared.debugKeychainState()
        
        // Test directo del Keychain
        let testToken = "test-token-123"
        print("Guardando token de prueba...")
        KeyChain.shared.saveToken(testToken)
        
        print("Leyendo token de prueba...")
        let retrieved = KeyChain.shared.getToken()
        print("Token recuperado: \(retrieved ?? "nil")")
        
        if retrieved == testToken {
            print("Keychain funciona correctamente")
        } else {
            print("Problema con el Keychain")
        }
    }
}

#Preview {
    TokenSetupView()
}
