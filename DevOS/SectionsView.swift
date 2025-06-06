//
//  SectionsView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 05/06/25.
//

import SwiftUI

struct SectionsView: View {
    let databaseItems: [DatabaseItem]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let onSelect: (DatabaseItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Secciones")
                .fontWeight(.semibold)
                .font(.system(size: 24))
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(databaseItems) { item in
                    SectionsItemView(item: item, onTap: {
                        onSelect(item)
                    })
                }
            }
        }
    }
}
