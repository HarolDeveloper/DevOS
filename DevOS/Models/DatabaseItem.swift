//
//  DatabaseItem.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 10/06/25.
//


import Foundation

struct DatabaseItem: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String

    static func == (lhs: DatabaseItem, rhs: DatabaseItem) -> Bool {
        lhs.id == rhs.id
    }
}