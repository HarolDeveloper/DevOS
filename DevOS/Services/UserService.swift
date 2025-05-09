//
//  UserService.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Foundation

class UserService {
    private let apiService = APIService.shared
    static let shared = UserService()
    
    private init() {}
    
    // Obtener perfil del usuario
    func getUserProfile() async throws -> User {
        return try await apiService.request(endpoint: "users/profile")
    }
    
    // Actualizar perfil del usuario
    func updateUserProfile(name: String) async throws -> User {
        let body: [String: Any] = ["name": name]
        return try await apiService.request(endpoint: "users/profile", method: "PUT", body: body)
    }
    
    // Cambiar contraseña
    func changePassword(currentPassword: String, newPassword: String) async throws -> Bool {
        let body: [String: Any] = [
            "currentPassword": currentPassword,
            "newPassword": newPassword
        ]
        
        struct Response: Codable {
            let success: Bool
        }
        
        let response: Response = try await apiService.request(
            endpoint: "users/change-password",
            method: "POST",
            body: body
        )
        
        return response.success
    }
}
