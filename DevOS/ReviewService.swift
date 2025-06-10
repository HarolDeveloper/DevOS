//
//  ReviewService.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 08/06/25.
//

import Supabase
import Foundation

struct Review: Codable {
    let id: UUID?
    let usuario_id: UUID
    let contenido: String
    let calificacion: Int
    let fecha_creacion: Date?
}

class ReviewService {
    static let shared = ReviewService()
    private let client = SupabaseManager.shared.client

    private init() {}

    func crearReview(
        usuarioId: UUID,
        contenido: String,
        calificacion: Int
    ) async throws {
        guard (1...5).contains(calificacion) else {
            throw NSError(
                domain: "ReviewService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "La calificación debe estar entre 1 y 5."]
            )
        }

        let nuevaReview = Review(
            id: nil,
            usuario_id: usuarioId,
            contenido: contenido,
            calificacion: calificacion,
            fecha_creacion: nil
        )

        print("📤 Enviando review para usuario:", usuarioId)
        try await client
            .from("review")
            .insert(nuevaReview)
            .execute()
    }

    func obtenerReviewsPorUsuario(usuarioId: UUID) async throws -> [Review] {
        let reviews: [Review] = try await client
            .from("review")
            .select()
            .eq("usuario_id", value: usuarioId)
            .order("fecha_creacion", ascending: false)
            .execute()
            .value

        return reviews
    }
}
