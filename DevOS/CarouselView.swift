//
//  CarouselView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 28/04/25.
//

import SwiftUI

struct CarouselView: View {
    let items: [CarouselItem]
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $currentIndex) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    CarouselItemView(item: item)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 150)
            .cornerRadius(10)
            
            // Custom dots overlaid on bottom-right
            HStack(spacing: 6) {
                Text("")
                ForEach(0..<items.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.white : Color.white.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(12)
        }
    }
}


