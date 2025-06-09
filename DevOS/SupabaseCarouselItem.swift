//
//  SupabaseCarouselItem.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 08/06/25.
//

import Foundation

struct SupabaseCarouselItem: Codable {
    let id: UUID
    let imageName: String
    let title: String
    let date: String
    let description: String
}
