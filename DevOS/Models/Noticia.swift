//
//  Noticia.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 08/06/25.
//

import Foundation

struct Noticia: Codable, Identifiable, Equatable {
    let id: UUID
    let fecha_publicacion: Date
    let imagen_url: String?
    let zona_id: UUID?
    let titulo: String?
    let descripcion: String?
}
