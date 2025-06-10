//
//  ZonaService.swift
//  DevOS
//
//  Created by Fernando Rocha on 08/06/25.
//

import Foundation
import Supabase

final class ZonaService {
    private let client = SupabaseManager.shared.client
    static let shared = ZonaService()
    @Published var zonas: [Zona] = []
    
    func obtenerTodasZonas() async throws -> [Zona] {
        let client = SupabaseManager.shared.client

        let response: PostgrestResponse<[Zona]> = try await client
            .from("zona")
            .select()
            .execute()

        return response.value
    }
    
    // Leer zonas
    func fetchZonas() async {
        do {
            let zonas: [Zona] = try await client
                .from("zona")
                .select()
                .execute()
                .value
            self.zonas = zonas
        } catch {
            print("❌ Error fetching instruments: \(error)")
        }
    }
}
