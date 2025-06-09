//
//  NoticiaService.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 08/06/25.
//

import Supabase
import Foundation

class NoticiaService {
    static let shared = NoticiaService()
    private let client = SupabaseManager.shared.client

    private init() {}

    func obtenerNoticias() async throws -> [Noticia] {
        let noticias: [Noticia] = try await client.database
            .from("noticia")
            .select()
            .order("fecha_publicacion", ascending: false)
            .execute()
            .value

        return noticias
    }
}
