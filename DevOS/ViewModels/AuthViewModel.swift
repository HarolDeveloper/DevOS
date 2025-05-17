//
//  AuthViewModel.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Combine
import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var errorMessage: String?

    private let authService = AuthService.shared

    init() {
        Task {
            await refreshSession()
        }
    }

    func signUp() async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.signUp(email: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = "Error al registrar: \(error.localizedDescription)"
            isLoggedIn = false
        }

        isLoading = false
    }

    func signIn() async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.signIn(email: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
            isLoggedIn = false
        }

        isLoading = false
    }

    func signOut() async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.signOut()
            isLoggedIn = false
        } catch {
            errorMessage = "Error al cerrar sesión: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func refreshSession() async {
        await authService.refreshSession()
        isLoggedIn = authService.user != nil
    }
}
