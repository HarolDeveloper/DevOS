//
//  SectionsItem.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 05/06/25.
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
