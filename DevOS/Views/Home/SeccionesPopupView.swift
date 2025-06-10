//
//  SeccionesPopupView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 14/05/25.
//

import SwiftUI

struct SectionsPopupView: View {
    let item: DatabaseItem
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: item.imageName)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(1.6, contentMode: .fill)
                            .frame(height: 100)
                            .clipped()
                            .cornerRadius(10)
                    case .failure:
                        Image("placeholder_zona")
                            .resizable()
                            .aspectRatio(1.6, contentMode: .fill)
                            .frame(height: 100)
                            .clipped()
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                    }
                }


                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title)
                        .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)
                Text(item.description)
                    .font(.body)
            }
            .padding()
            .frame(maxWidth: 360)
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding()
        .shadow(radius: 10)
        .frame(maxWidth: 360)
    }
}
