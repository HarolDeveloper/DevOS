//
//  OnboardingView.swift
//  DevOS
//
//  Created by Bernardo Caballero on 08/05/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var intereses: [String]
    @Binding var selectedTags: Set<String>
    var onFinish: () -> Void

    let interesesDisponibles: [(id: String, display: String)] = [
        (id: "historia", display: "🏛️ Historia"),
        (id: "vistas", display: "📸 Aventura y vistas"),
        (id: "interaccion", display: "🎡 Interacción"),
        (id: "tecnologia", display: "🔥 Tecnología"),
        (id: "ciencia", display: "🧪 Ciencia"),
        (id: "familiar", display: "👨‍👩‍👧‍👦 Familiar / Niños"),
        (id: "ingenieria", display: "💡 Ingeniería"),
        (id: "medio_ambiente", display: "🌍 Medio Ambiente")
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Encabezado estilizado
            VStack(spacing: 6) {
                Text("¡Cuéntanos tus gustos!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Elige las opciones que más te interesen")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            VStack(spacing: 14) {
                ForEach(0..<interesesDisponibles.count / 2, id: \.self) { rowIndex in
                    HStack(spacing: 12) {
                        tagButton(for: interesesDisponibles[rowIndex * 2])
                            .frame(maxWidth: .infinity, alignment: .leading)
                        tagButton(for: interesesDisponibles[rowIndex * 2 + 1])
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .padding(.top)
    }

    private func tagButton(for tag: (id: String, display: String)) -> some View {
        Button(action: {
            toggle(tag: tag.id)
        }) {
            Text(tag.display)
                .fontWeight(.medium)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedTags.contains(tag.id) ? Color.orange.opacity(0.15) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedTags.contains(tag.id) ? Color.orange : Color.gray.opacity(0.4), lineWidth: 1)
                        )
                )
                .foregroundColor(.black)
        }
    }

    private func toggle(tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}


#Preview {
    OnboardingView(
        intereses: .constant([]),
        selectedTags: .constant(["tecnologia", "medio_ambiente"]),
        onFinish: {}
    )
}
