//
//  provisionalView.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 2/9/25.
//

import SwiftUI
import KeychainSwift

struct provisionalView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Spacer()
            Text("Ya tengo el token")
                .font(.title)
            Text("Aqui tendria que ir la pagina principal")
                .font(.caption)
        
            Spacer()
            
            Button("Resetear token") {
                appState.deleteToken()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            
            
        }
        .padding(50)
    }
}

#Preview {
    provisionalView()
}
