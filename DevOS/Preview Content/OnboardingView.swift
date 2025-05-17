//
//  OnboardingView.swift
//  DevOS
//
//  Created by Bernardo Caballero on 08/05/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selectedTags: Set<String> = []
    @State private var goToMainApp = false

    // Etiquetas organizadas por filas
    let tagRows: [[String]] = [
        ["🏛️ Historia", "📸 Aventura y vistas"],
        ["🎡 Interacción", "🔥 Tecnología"],
        ["🧪 Ciencia", "👨‍👩‍👧‍👦 Familiar / Niños"],
        ["💡 Ingeniería", "🌍 Medio Ambiente"]
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                ZStack(alignment: .bottom) {
                    Color(red: 0.996, green: 0.486, blue: 0.251)
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 250)

                    Image("horno3_Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)

                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.white)
                        .frame(height: 70)
                        .offset(y: 35)
                }

                VStack(spacing: 8) {
                    Text("¡Cuéntanos tus gustos!")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("¡Elige las opciones que más te parezcan interesantes!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top)

                // Botones perfectamente alineados
                VStack(spacing: 15) {
                    ForEach(tagRows, id: \.self) { row in
                        HStack {
                            // Botón izquierdo alineado a la izquierda
                            Button(action: {
                                toggle(tag: row[0])
                            }) {
                                Text(row[0])
                                    .fontWeight(.medium)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .fixedSize()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedTags.contains(row[0]) ? Color.orange.opacity(0.15) : Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(selectedTags.contains(row[0]) ? Color.orange : Color.gray.opacity(0.4), lineWidth: 1)
                                            )
                                    )
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // Botón derecho alineado a la derecha
                            Button(action: {
                                toggle(tag: row[1])
                            }) {
                                Text(row[1])
                                    .fontWeight(.medium)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .fixedSize()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedTags.contains(row[1]) ? Color.orange.opacity(0.15) : Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(selectedTags.contains(row[1]) ? Color.orange : Color.gray.opacity(0.4), lineWidth: 1)
                                            )
                                    )
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
                .padding(.horizontal, 30)

                Spacer()

                Button("Continuar") {
                    goToMainApp = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.996, green: 0.486, blue: 0.251))
                .cornerRadius(25)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationDestination(isPresented: $goToMainApp) {
                NavBarView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    // Para evitar repetir lógica
    private func toggle(tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}

#Preview {
    OnboardingView()
}
