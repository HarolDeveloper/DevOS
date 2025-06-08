//
//  LoadingView.swift
//  DevOS
//
//  Created by Bernardo Caballero on 08/05/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color(red: 0.969, green: 0.353, blue: 0.074)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("horno3_Loading")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .opacity(animate ? 0.5 : 1.0)
                    .scaleEffect(animate ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animate)

                Text("Cargando...")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
                    .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation {
                animate = true
            }
        }
    }
}

#Preview {
    LoadingView()
}
