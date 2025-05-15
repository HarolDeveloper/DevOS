//
//  AuthService.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    private let apiService = APIService.shared
    private let tokenKey = "authToken"
    private let userDefaultsKey = "currentUser"
    
    private init() {
        // Restaurar token guardado en UserDefaults si existe
        if let savedToken = UserDefaults.standard.string(forKey: tokenKey) {
            apiService.setAuthToken(savedToken)
        }
    }
    
    var isAuthenticated: Bool {
        return UserDefaults.standard.string(forKey: tokenKey) != nil
    }
    
    // Registro de nuevo usuario
    func register(email: String, password: String, name: String) async throws -> User {
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "name": name
        ]
        
        let authResponse: AuthResponse = try await apiService.request(
            endpoint: "auth/register",
            method: "POST",
            body: body
        )
        
        // Guardar token y usuario
        saveAuthState(token: authResponse.token, user: authResponse.user)
        
        return authResponse.user
    }
    
    // Inicio de sesión
    func login(email: String, password: String) async throws -> User {
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let authResponse: AuthResponse = try await apiService.request(
            endpoint: "auth/login",
            method: "POST",
            body: body
        )
        
        // Guardar token y usuario
        saveAuthState(token: authResponse.token, user: authResponse.user)
        
        return authResponse.user
    }
    
    // Cerrar sesión
    func logout() {
        // Limpiar token y usuario
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        apiService.clearAuthToken()
    }
    
    // Guardar estado de autenticación
    private func saveAuthState(token: String, user: User) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        apiService.setAuthToken(token)
        
        // Guardar usuario
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
        }
    }
    
    // Obtener usuario actual
    func getCurrentUser() -> User? {
        guard let userData = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return nil
        }
        
        return try? JSONDecoder().decode(User.self, from: userData)
    }
}
