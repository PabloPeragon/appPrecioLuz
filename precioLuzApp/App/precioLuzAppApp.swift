//
//  precioLuzAppApp.swift
//  baseApp
//
//  Created by Pablo Peragón Garrido on 20/8/25.
//

import SwiftUI
import KeychainSwift

@main
struct precioLuzAppApp: App {
    @StateObject private var appState = AppState()
    
    
    var body: some Scene {
        WindowGroup {
            RouterView()
                .environmentObject(appState)
        
        }
    }
}
