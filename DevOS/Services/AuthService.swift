//
//  AuthService.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Foundation
import Combine
import Supabase


class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://vhdoljnhrltfbqcnuijj.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZoZG9sam5ocmx0ZmJxY251aWpqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3NTk1ODEsImV4cCI6MjA2MjMzNTU4MX0.69qk8uyN5zz79MgiGrfh7bZ318HAiqcYXOhSgHp5MPM"
        )
    }
}


class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let supabase = SupabaseManager.shared.client

    @Published var session: Session?
    @Published var user: Auth.User?
    @Published var usuario: Usuario?

    private init() {
        Task { await refreshSession() }
    }

    // MARK: - Sign Up

    func signUp(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(email: email, password: password)
        self.session = response.session
        self.user = response.user

        try await registrarUsuario(email: email)
    }


    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(email: email, password: password)
        self.session = session
        self.user = session.user
        try await obtenerUsuario()
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
        self.session = nil
        self.user = nil
        self.usuario = nil
    }
    
    func cambiarContrasena(nueva: String) async throws {
        try await supabase.auth.update(user: UserAttributes(password: nueva))
    }

    func refreshSession() async {
        do {
            let session = try await supabase.auth.session
            self.session = session
            self.user = session.user
            try await obtenerUsuario()
        } catch {
            self.session = nil
            self.user = nil
            self.usuario = nil
        }
    }


    private func registrarUsuario(email: String) async throws {
        guard let userId = user?.id.uuidString else { return }

        let existentes: [Usuario] = try await supabase
            .from("usuario")
            .select()
            .eq("id", value: userId)
            .execute()
            .value

        if existentes.isEmpty {
            let nuevo = [
                "id": userId,
                "auth_user_id": userId,
                "email": email,
                "tipo_usuario": "visitante",
                "fecha_creacion": ISO8601DateFormatter().string(from: Date())
            ]
            try await supabase.from("usuario").insert([nuevo]).execute()
        }

        try await obtenerUsuario()
    }

    private func obtenerUsuario() async throws {
        guard let userId = user?.id.uuidString else { return }

        let resultado: [Usuario] = try await supabase
            .from("usuario")
            .select()
            .eq("id", value: userId)
            .execute()
            .value

        self.usuario = resultado.first
    }

    var accessToken: String? {
        session?.accessToken
    }
}
