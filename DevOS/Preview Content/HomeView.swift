//
//  HomeView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 28/04/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedCarouselItem: CarouselItem? = nil
    @State private var selectedSectionItem: DatabaseItem? = nil
    @Environment(\.colorScheme) var colorScheme

    @State private var isSearching: Bool = false

    let sampleItems = [
        CarouselItem(
            imageName: "image1",
            title: "¡Apertura de nueva zona!",
            date: "24 de abril de 2025",
            description: "Inauguramos una nueva área interactiva con acceso libre y espacios renovados."
        ),
        CarouselItem(
            imageName: "image2",
            title: "Nueva exposición de arte",
            date: "28 de abril de 2025",
            description: "Conoce la nueva exposición sobre arte industrial y procesos metalúrgicos."
        ),
        CarouselItem(
            imageName: "image3",
            title: "Mantenimiento programado",
            date: "2 de mayo de 2025",
            description: "El área sur estará cerrada por mantenimiento preventivo durante 48 horas."
        )
    ]

    struct DatabaseItem {
        let imageName: String
        let title: String
        let description: String
    }

    let databaseItems = [
        DatabaseItem(imageName: "infoImage", title: "Escaleras caracol", description: "Por aquí se sube al segundo piso del museo."),
        DatabaseItem(imageName: "updateImage", title: "Museo de acero", description: "Aquí podrás realizar distintas actividaades."),
        DatabaseItem(imageName: "featureImage", title: "Arquitectura", description: "Algunos de los diseños más sorprendentes del parque."),
        DatabaseItem(imageName: "maintenanceImage", title: "Museo de historia", description: "Aquí podrás aprender sobre el horno 3.")
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Encabezado con título y ajustes
                    HStack {
                        Text("¡Bienvenido!")
                            .fontWeight(.semibold)
                            .font(.system(size: 24))
                            .padding(.leading)

                        Spacer()

                        NavigationLink(destination: SettingsView()) {
                            Image("Settings")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding(.trailing)
                        }
                    }
                    .padding(.top)

                    // Barra de búsqueda
                    NavigationLink(destination: SearchView(isPresented: $isSearching), isActive: $isSearching) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            Text("¿Qué estás buscando hoy?")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(12)
                        .background(colorScheme == .dark ? Color(.systemGray5).opacity(0.7) : Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Carrusel
                    CarouselView(items: sampleItems) { item in
                        selectedCarouselItem = item
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding()

                    // Sección "Secciones"
                    Text("Secciones")
                        .fontWeight(.semibold)
                        .font(.system(size: 24))
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(databaseItems, id: \.title) { item in
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
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                    }
                }
            }

            // Popup de Carousel
            .overlay(
                Group {
                    if let selected = selectedCarouselItem {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedCarouselItem = nil
                                }
                            }

                        CarouselPopupView(item: selected) {
                            withAnimation(.spring()) {
                                selectedCarouselItem = nil
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                    }
                }
            )
            .animation(.spring(), value: selectedCarouselItem)
            .background(Color(.systemBackground)) // fondo de NavigationStack
        }
    }
}


#Preview {
    HomeView()
}
