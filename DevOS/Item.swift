//
//  Item.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 25/04/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
