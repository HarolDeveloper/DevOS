//
//  SectionsItemView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 05/06/25.
//

import SwiftUI

struct SectionsItemView: View {
    let item: DatabaseItem
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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

            Text(item.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(Color.white)
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
}
