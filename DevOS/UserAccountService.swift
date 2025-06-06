//
//  UserAccountService.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 05/06/25.
//

import Foundation
import Supabase

@MainActor
class UserAccountService: ObservableObject {
    static let shared = UserAccountService()
    private let client = SupabaseManager.shared.client

    private init() {}

    /// Cambia la contraseña del usuario actualmente autenticado
    func cambiarContrasena(nueva: String) async throws {
        try await client.auth.update(user: UserAttributes(password: nueva))
    }
}
