//
//  RouteSheetView.swift
//  DevOS
//
//  Created by Fernando Rocha on 05/06/25.
//

import SwiftUI

struct RouteCardView: View {
    var number: String
    var title: String
    var image: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "photo") // Reemplaza con imagen real si aplica
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 110)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(14)

            Text(number)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(title)
                .font(.headline)
                .bold()
        }
        .frame(width: 180)
    }
}

struct RouteSheetView: View {
    var estimatedTime: String // ej. "30 min"
    @Binding var isPresented: Bool
    var onDismiss: () -> Void

    @State private var isCollapsed: Bool = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.4)

    var body: some View {
        VStack(spacing: 16) {
            if !isCollapsed {
                Text("¡Sigue esta ruta!")
                    .font(.title2)
                    .bold()
                    .padding(.top, 4)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        RouteCardView(number: "#1", title: "Galería de historia", image: "historia")
                        RouteCardView(number: "#2", title: "Reacción en Cadena", image: "ciencia")
                        // Puedes agregar más tarjetas aquí
                    }
                    .padding(.horizontal)
                }

                HStack {
                    Button(action: {
                        isPresented = false
                        onDismiss()
                    }) {
                        Text("Salir")
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .background(Color.red)
                            .cornerRadius(14)
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Text("Tiempo estimado")
                        Circle()
                            .frame(width: 6, height: 6)
                        Text(estimatedTime)
                            .bold()
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal)
            } else {
                HStack(spacing: 16) {
                    Text("Tiempo estimado")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                    Circle()
                        .frame(width: 6, height: 6)
                    Text(estimatedTime)
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                        .bold()
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .padding(.top)
        .presentationDetents(
            [.fraction(0.15), .fraction(0.4)],
            selection: $selectedDetent
        )
        .interactiveDismissDisabled()
        .onChange(of: selectedDetent) { newValue in
            withAnimation {
                isCollapsed = newValue == .fraction(0.15)
            }
        }
        .onAppear {
            isCollapsed = false
            selectedDetent = .fraction(0.4)
        }
    }
}
