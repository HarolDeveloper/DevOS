//
//  AuthResponse.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Foundation

struct AuthResponse: Codable {
    let token: String
    let user: User
}
