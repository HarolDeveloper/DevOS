//
//  CarouselItem.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 28/04/25.
//

import Foundation

struct CarouselItem: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let title: String
    let date: String
    let description: String

    static func == (lhs: CarouselItem, rhs: CarouselItem) -> Bool {
        lhs.id == rhs.id
    }
}
