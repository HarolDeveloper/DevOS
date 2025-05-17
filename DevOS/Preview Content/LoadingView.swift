//
//  LoadingView.swift
//  DevOS
//
//  Created by Bernardo Caballero on 08/05/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var fade = false

    var body: some View {
        ZStack {
            Color(red: 0.969, green: 0.353, blue: 0.074)
                .ignoresSafeArea()

            Image("horno3_Loading")
                .resizable()
                .scaledToFit()
                .frame(width: 350)
                .opacity(fade ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: fade)
        }
        .onAppear {
            fade = true
        }
    }
}

#Preview {
    LoadingView()
}
