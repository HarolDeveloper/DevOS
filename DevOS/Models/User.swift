//
//  User.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 29/04/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let username: String
    let email: String
    let name: String
}

