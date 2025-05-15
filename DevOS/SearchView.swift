//
//  SearchView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 14/05/25.
//

import SwiftUI

struct SearchView: View {
    @Binding var isPresented: Bool
    @State private var searchText = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    isPresented = false // ✅ Cierra y permite volver a abrir
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }

                TextField("¿Qué estás buscando?", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding()

            Text("Lo más buscado")
                .font(.headline)
                .padding(.horizontal)

            List {
                ForEach(["Horno", "Planeta Tierra", "Museo de historia"], id: \.self) { term in
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                            .overlay(Text(term.prefix(1)).font(.headline))
                        Text(term)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
