//
//  ZonaService.swift
//  DevOS
//
//  Created by Fernando Rocha on 08/06/25.
//

import Foundation
import Supabase

final class ZonaService {
    static let shared = ZonaService()

    func obtenerTodasZonas() async throws -> [Zona] {
        let client = SupabaseManager.shared.client

        let response: PostgrestResponse<[Zona]> = try await client
            .from("zona")
            .select()
            .execute()

        return response.value
    }
}
