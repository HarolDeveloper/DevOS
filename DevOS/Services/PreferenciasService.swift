//
//  PreferenciasService.swift
//  DevOS
//
//  Created by Bernardo Caballero on 02/06/25.
//

import Foundation
import Supabase

@MainActor
class PreferenciaService: ObservableObject {
    private let client = SupabaseManager.shared.client

    /// Guarda las preferencias de visita en Supabase
    func guardarPreferencias(preferencia: PreferenciaVisita) async throws {
        try await client
            .from("preferenciavisita")
            .insert([preferencia])
            .execute()
    }

    /// Verifica si el usuario ya tiene preferencias registradas
    func verificarPreferenciasUsuario(userId: String) async throws -> Bool {
        do {
            let preferencias: [PreferenciaVisita] = try await client
                .from("preferenciavisita")
                .select()
                .eq("usuario_id", value: userId)
                .execute()
                .value
            
            let tienePreferencias = !preferencias.isEmpty
            print("🔍 Preferencias encontradas para \(userId): \(tienePreferencias)")
            return tienePreferencias
        } catch {
            print("❌ Error al verificar preferencias para \(userId):", error.localizedDescription)
            return false
        }
    }
}
