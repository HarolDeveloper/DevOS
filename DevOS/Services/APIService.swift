//
//  APIService.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case requestFailed(Error)
    case authenticationError
}

class APIService {
    private let baseURL = "https://api.example.com"
    private var authToken: String?
    
    // Singleton
    static let shared = APIService()
    
    private init() {}
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    // Método genérico para peticiones HTTP
    func request<T: Decodable>(endpoint: String, method: String = "GET", body: [String: Any]? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Añadir token de autenticación si existe
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Añadir cuerpo de la petición si existe
        if let body = body {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                throw APIError.authenticationError
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.requestFailed(error)
        }
    }
}
