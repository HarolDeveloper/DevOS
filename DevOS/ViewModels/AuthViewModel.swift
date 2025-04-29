//
//  AuthViewModel.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    private let authService = AuthService.shared
    
    // Estado de autenticación
    @Published var isAuthenticated: Bool = false
    
    // Usuario actual
    @Published var currentUser: User?
    
    // Estado de la petición
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        // Verificar si ya existe sesión guardada
        isAuthenticated = authService.isAuthenticated
        currentUser = authService.getCurrentUser()
    }
    
    // Función de registro
    func register(email: String, password: String, name: String) async {
        isLoading = true
        error = nil
        
        do {
            currentUser = try await authService.register(email: email, password: password, name: name)
            isAuthenticated = true
        } catch {
            self.error = handleError(error)
        }
        
        isLoading = false
    }
    
    // Función de inicio de sesión
    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        
        do {
            currentUser = try await authService.login(email: email, password: password)
            isAuthenticated = true
        } catch {
            self.error = handleError(error)
        }
        
        isLoading = false
    }
    
    // Función de cierre de sesión
    func logout() {
        authService.logout()
        isAuthenticated = false
        currentUser = nil
    }
    
    // Manejador de errores para presentar mensajes al usuario
    private func handleError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .authenticationError:
                return "Error de autenticación. Verifica tus credenciales."
            case .invalidResponse:
                return "La respuesta del servidor no es válida."
            case .invalidData:
                return "Los datos recibidos no son válidos."
            case .invalidURL:
                return "La URL no es válida."
            case .requestFailed(let err):
                return "Error de red: \(err.localizedDescription)"
            }
        }
        
        return "Error desconocido: \(error.localizedDescription)"
    }
}

