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
    @State private var zonas: [Zona] = []
    @State private var selectedZona: Zona? = nil
    @State private var isLoading = true
    

    var filteredZonas: [Zona] {
        if searchText.isEmpty {
            return zonas
        } else {
            return zonas.filter {
                $0.nombre.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
        
                    TextField("search_placeholder".localized, text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding()

                Text("zones_found".localized)
                    .font(.headline)
                    .padding(.horizontal)

                if isLoading {
                    ProgressView("Cargando zonas...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if filteredZonas.isEmpty {
                    Text("No se encontraron zonas.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredZonas) { zona in
                        Button(action: {
                            selectedZona = zona
                        }) {
                            HStack {
                                AsyncImage(url: URL(string: zona.imageURL!)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(8)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .frame(width: 40, height: 40)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                Text(zona.nombre)
                                    .padding(.leading, 8)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }

            if let zona = selectedZona {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        selectedZona = nil
                    }

                SectionsPopupView(item: DatabaseItem(
                    imageName: zona.imageURL!,
                    title: zona.nombre,
                    description: zona.descripcion
                )) {
                    selectedZona = nil
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                do {
                    isLoading = true
                    zonas = try await ZonaService.shared.obtenerTodasZonas()
                } catch {
                    print("❌ Error cargando zonas: \(error)")
                }
                isLoading = false
            }
        }
    }
}
