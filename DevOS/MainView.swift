//
//  MainView.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
              
            } else {
              
            }
        }
        .environmentObject(authViewModel)
    }
}

#Preview {
    MainView()
}
