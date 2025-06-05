//
//  User.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Foundation

struct Usuario: Codable {
    let id: String
    let auth_user_id: String
    let email: String
    let nombre: String?
    let tipo_usuario: String?
    let edad: Int?
    let fecha_creacion: String?
}
