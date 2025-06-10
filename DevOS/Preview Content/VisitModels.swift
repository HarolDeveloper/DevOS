//
//  VisitModels.swift
//  DevOS
//
//  Created by Fernando Rocha on 08/06/25.
//

import Foundation

struct Zona: Codable, Identifiable {
    let id: UUID
    let nombre: String
    let actividad: String // "baja", "media", "alta"
    let categorias: [String]
    let nivel: Int
    let duracion: Int // en minutos
}

struct Visita: Codable {
    let id: UUID
    let usuario_id: UUID
    let tiempo_disponible: Int // en minutos
}


func calcularRutaOptima(
    zonas: [Zona],
    visita: Visita,
    preferencias: PreferenciaVisita
) -> [Zona] {
    // Filtrar zonas según restricciones del usuario
    let zonasFiltradas = zonas.filter { zona in
        if preferencias.restriccion_mayores && zona.actividad == "alta" { return false }
        if preferencias.restriccion_movilidad && zona.actividad != "baja" { return false }
        if preferencias.restriccion_actividad_alta && zona.actividad == "alta" { return false }
        return true
    }

    // Asignar puntaje según actividad preferida
    func puntajeActividad(_ actividad: String) -> Int {
        switch (actividad, preferencias.actividad_preferida) {
        case ("baja", "baja"), ("media", "media"), ("alta", "alta"):
            return 3
        case ("baja", "media"), ("media", "baja"), ("media", "alta"), ("alta", "media"):
            return 2
        default:
            return 1
        }
    }

    // Asignar puntaje según intereses
    func puntajeInteres(zona: Zona) -> Int {
        zona.categorias.filter { preferencias.intereses.contains($0) }.count
    }

    // Calcular puntaje total
    let zonasConPuntaje = zonasFiltradas.map { zona in
        let score = puntajeActividad(zona.actividad)
                  + puntajeInteres(zona: zona)
                  + (3 - zona.nivel)
        return (zona, score)
    }

    // Ordenar por mayor puntaje
    let ordenadas = zonasConPuntaje.sorted { $0.1 > $1.1 }

    // Seleccionar zonas que caben en el tiempo disponible
    var tiempoRestante = visita.tiempo_disponible
    var ruta: [Zona] = []

    for (zona, _) in ordenadas {
        if zona.duracion <= tiempoRestante {
            ruta.append(zona)
            tiempoRestante -= zona.duracion
        }
    }

    return ruta
}
