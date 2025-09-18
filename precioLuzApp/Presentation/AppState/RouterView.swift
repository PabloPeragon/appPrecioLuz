//
//  RouterView.swift
//  precioLuzApp
//
//  Created by Pablo Peragón Garrido on 5/9/25.
//

import SwiftUI

struct RouterView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.hasToken {
            HomeView() // aranque de la app normal
            //provisionalView() //arranque para introducir o resetear token
        } else {
            TokenSetupView()
        }
    }
}

#Preview {
    RouterView()
}
