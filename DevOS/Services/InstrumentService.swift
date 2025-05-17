//
//  InstrumentService.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Foundation
import Supabase

@MainActor
class InstrumentService: ObservableObject {
    private let client = SupabaseManager.shared.client

    @Published var instruments: [Instrument] = []

    // Leer instrumentos
    func fetchInstruments() async {
        do {
            let instruments: [Instrument] = try await client
                .from("instruments")
                .select()
                .execute()
                .value
            self.instruments = instruments
        } catch {
            print("❌ Error fetching instruments: \(error)")
        }
    }

    // Insertar un nuevo instrumento
    func insertInstrument(_ instrument: Instrument) async {
        do {
            try await client
                .from("instruments")
                .insert(instrument)
                .execute()
        } catch {
            print("❌ Error inserting instrument: \(error)")
        }
    }

    // Actualizar un instrumento existente
    func updateInstrument(id: Int, newName: String) async {
        do {
            try await client
                .from("instruments")
                .update(["name": newName])
                .eq("id", value: id)
                .execute()
        } catch {
            print("❌ Error updating instrument: \(error)")
        }
    }

    // Insertar o actualizar un instrumento
    func upsertInstrument(_ instrument: Instrument) async {
        do {
            try await client
                .from("instruments")
                .upsert(instrument)
                .execute()
        } catch {
            print("❌ Error upserting instrument: \(error)")
        }
    }
}
