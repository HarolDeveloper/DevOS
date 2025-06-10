//
//  NoticiasCarruselView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 08/06/25.
//

import SwiftUI

struct NoticiaCarouselView: View {
    let noticias: [Noticia]
    let onTap: (Noticia) -> Void
    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $currentIndex) {
                ForEach(Array(noticias.enumerated()), id: \.element.id) { index, noticia in
                    NoticiaCarouselItemView(noticia: noticia)
                        .onTapGesture {
                            onTap(noticia)
                        }
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 150)
            .cornerRadius(10)

            HStack {
                Text(noticias[currentIndex].titulo ?? "Sin título")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.5))
                    .cornerRadius(8)

                Spacer()

                HStack(spacing: 6) {
                    ForEach(0..<noticias.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(12)
        }
    }
}
