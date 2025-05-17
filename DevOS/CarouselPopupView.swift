//
//  CarouselPopupView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 09/05/25.
//

import SwiftUI

struct CarouselPopupView: View {
    let item: CarouselItem
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                    .clipped()


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
                Text(item.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true) // ✅ permite salto de línea
                    .lineLimit(nil)

                Text("Creado el \(item.date)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(item.description)
                    .font(.body)
            }
            .padding()
            .frame(maxWidth: 360) // o el valor que prefieras
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding()
        .shadow(radius: 10)
        .frame(maxWidth: 360) // o el valor que prefieras
    }
}
