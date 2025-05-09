//
//  CarouselItemView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 28/04/25.
//

import SwiftUI

struct CarouselItemView: View {
    let item: CarouselItem
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipped()
                .cornerRadius(15)
                .shadow(radius: 5)
            
            Text(item.title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                .padding([.leading, .bottom], 10)
        }
    }
}
