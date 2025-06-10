//
//  SectionsItemView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 05/06/25.
//

import SwiftUI

struct SectionsItemView: View {
    let item: DatabaseItem
    let onTap: () -> Void  // ✅ esto es lo nuevo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(1.6, contentMode: .fill)
                .frame(height: 100)
                .clipped()
                .cornerRadius(10)

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
            onTap()  // ✅ ahora responde al toque
        }
    }
}
