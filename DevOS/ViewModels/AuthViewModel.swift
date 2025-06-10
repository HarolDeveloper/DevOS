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
    @Published var isInitializing = true
    @Published var hasCompletedOnboarding = false
    @Published var errorMessage: String?
    
    private let preferenciaService = PreferenciaService()
    private let authService = AuthService.shared


    init() {
        Task {
            await refreshSession()
            await MainActor.run {
                self.isInitializing = false
            }
        }
    }

    func signUp() async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.signUp(email: email, password: password)
            isLoggedIn = true
            hasCompletedOnboarding = false
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
            await checkOnboardingStatus()
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
            await MainActor.run {
                hasCompletedOnboarding = false
                isLoggedIn = false
                email = ""
                password = ""
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error al cerrar sesión: \(error.localizedDescription)"
            }
        }

        isLoading = false
    }


    func refreshSession() async {
        await authService.refreshSession()
        isLoggedIn = authService.user != nil
        if isLoggedIn {
            await checkOnboardingStatus()
        }
    }
    
    // ✅ Nueva función para verificar el estado del onboarding
    private func checkOnboardingStatus() async {
        guard let userId = authService.user?.id.uuidString else {
            hasCompletedOnboarding = false
            return
        }
        
        do {
            hasCompletedOnboarding = try await preferenciaService.verificarPreferenciasUsuario(userId: userId)
        } catch {
            print("❌ Error verificando onboarding:", error)
            hasCompletedOnboarding = false
        }
    }
    
    // ✅ Función para marcar onboarding como completado
    func markOnboardingCompleted() {
        hasCompletedOnboarding = true
    }
}
