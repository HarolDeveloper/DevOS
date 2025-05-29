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



@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    private let supabase = SupabaseManager.shared.client

    @Published var session: Session?
    @Published var user: Auth.User?

    private init() {
        Task {
            await refreshSession()
        }
    }

    func signUp(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(email: email, password: password)
        self.session = response.session
        self.user = response.user

        let userId = response.user.id.uuidString

        try await supabase
            .from("usuario")
            .insert([
                "auth_user_id": userId,
                "email": email,
                "fecha_creacion": ISO8601DateFormatter().string(from: Date()),
                "tipo_usuario": "visitante"
            ])
            .execute()
    }


    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(email: email, password: password)
        self.session = session
        self.user = session.user
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
        self.session = nil
        self.user = nil
    }

    func refreshSession() async {
        do {
            let session = try await supabase.auth.session
            self.session = session
            self.user = session.user
        } catch {
            self.session = nil
            self.user = nil
        }
    }

    var accessToken: String? {
        session?.accessToken
    }
}
