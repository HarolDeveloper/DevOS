//
//  ExperienceTitles.swift
//  DevOS
//
//  Created by Fernando Rocha on 08/05/25.
//

import Foundation

struct Experience: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String

}

struct ExperienceData {
    static let all: [Experience] = [
        Experience(title: "Galería de la historia", emoji: "🏛️"),
        Experience(title: "Show del horno", emoji: "🔥"),
        Experience(title: "Paseo por la cima", emoji: "🌄"),
        Experience(title: "Una ventana a la ciencia", emoji: "🧪"),
        Experience(title: "Galería del Acero", emoji: "🕹️"),
        Experience(title: "Planeta Tierra", emoji: "🌍"),
        Experience(title: "Reacción en Cadena", emoji: "⛓️"),
        Experience(title: "Laboratorio de Innovación", emoji: "🔬"),
        Experience(title: "Taquilla", emoji: "🎟️"),
        Experience(title: "Segundo Piso", emoji: "⬆️"),
        Experience(title: "Entrada", emoji: "🚪"),
        Experience(title: "El Lingote", emoji: "🍽️")
    ]
}
