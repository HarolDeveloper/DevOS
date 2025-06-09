//
//  NoticiaPopupView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 08/06/25.
//

import SwiftUI

struct NoticiaPopupView: View {
    let noticia: Noticia
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let urlStr = noticia.imagen_url, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                    .clipped()
                }

                Button(action: {
                    onClose()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title)
                        .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(noticia.titulo ?? "")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Publicado el \(formattedDate(noticia.fecha_publicacion))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(noticia.descripcion ?? "")
                    .font(.body)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding()
        .shadow(radius: 10)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
