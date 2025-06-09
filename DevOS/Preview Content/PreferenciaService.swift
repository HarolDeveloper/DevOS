//
//  PreferenciaService.swift
//  DevOS
//
//  Created by Fernando Rocha on 08/06/25.
//

import Foundation
import Supabase

final class PreferenciaService {
    static let shared = PreferenciaService()

    func obtenerPorUsuario(_ usuarioId: UUID) async throws -> PreferenciaVisita {
        let client = SupabaseManager.shared.client

        let response: PostgrestResponse<PreferenciaVisita> = try await client
            .from("preferenciavisita")
            .select()
            .eq("usuario_id", value: usuarioId.uuidString)
            .single()
            .execute()

        return response.value
    }
}
