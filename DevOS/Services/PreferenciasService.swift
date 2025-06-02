//
//  PreferenciasService.swift
//  DevOS
//
//  Created by Bernardo Caballero on 02/06/25.
//


import Foundation

func guardarPreferencias(preferencia: PreferenciaVisita) async throws {
    let client = SupabaseManager.shared.client

    try await client
        .from("PreferenciaVisita")
        .insert([preferencia])
        .execute()
}
