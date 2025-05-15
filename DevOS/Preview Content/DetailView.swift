//
//  DetailView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 08/05/25.
//

import SwiftUI

struct DetailView: View {
    var item: CarouselItem

    var body: some View {
        VStack {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .padding()

            Text(item.title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()
        }
        .navigationBarTitle("Detalle", displayMode: .inline)
    }
}
