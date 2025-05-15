//
//  MainView.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
              NavBarView()
            } else {
              NavBarView()
            }
        }
        .environmentObject(authViewModel)
    }
}


#Preview {
    MainView().modelContainer(for: [], inMemory: true)
}
