//
//  NoticiaCarruselItemView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 08/06/25.
//

import SwiftUI

struct NoticiaCarouselItemView: View {
    let noticia: Noticia

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let urlStr = noticia.imagen_url, let url = URL(string: urlStr) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 300)
                .clipped()
                .cornerRadius(15)
                .shadow(radius: 5)
            } else {
                Color.gray
                    .frame(height: 300)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }

            Text(noticia.titulo ?? "Sin título")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.orange.opacity(0.6))
                .cornerRadius(10)
                .padding([.leading, .bottom], 10)
        }
    }
}
