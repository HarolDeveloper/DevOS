//
//  PreferenciaVisita.swift
//  DevOS
//
//  Created by Fernando Rocha on 09/06/25.
//

import SwiftUI

struct PreferenciaVisita: Codable {
    let usuario_id: String
    let tipo_acompanantes: String
    let actividad_preferida: String
    let desea_show: Bool
    let restriccion_mayores: Bool
    let restriccion_movilidad: Bool
    let restriccion_actividad_alta: Bool
    let intereses: [String]
}
