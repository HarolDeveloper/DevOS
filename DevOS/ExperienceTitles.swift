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
    let position: CGPoint
}

struct ExperienceData {
    static let all: [Experience] = [
        Experience(title: "Galería de la historia", emoji: "🏛️", position: CGPoint(x: 0.23, y: 0.25)),
        Experience(title: "Show del horno", emoji: "🔥", position: CGPoint(x: 0.52, y: 0.45)),
        Experience(title: "Paseo por la cima", emoji: "🌄", position: CGPoint(x: 0.75, y: 0.32)),
        Experience(title: "Una ventana a la ciencia", emoji: "🧪", position: CGPoint(x: 0.25, y: 0.18)),
        Experience(title: "Galería del Acero", emoji: "🕹️", position: CGPoint(x: 0.25, y: 0.75)),
        Experience(title: "Planeta Tierra", emoji: "🌍", position: CGPoint(x: 0.50, y: 0.50)),
        Experience(title: "Reacción en Cadena", emoji: "⛓️", position: CGPoint(x: 0.72, y: 0.12)),
        Experience(title: "Laboratorio de Innovación", emoji: "🔬", position: CGPoint(x: 0.75, y: 0.75))
    ]
}
