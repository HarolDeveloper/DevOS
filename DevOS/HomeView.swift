//
//  HomeView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 28/04/25.
//

import SwiftUI

struct HomeView: View {
    let sampleItems = [
        CarouselItem(imageName: "image1", title: "Image 1"),
        CarouselItem(imageName: "image2", title: "Image 2"),
        CarouselItem(imageName: "image3", title: "Image 3")
    ]

    // Simulando datos de base de datos
    let databaseItems = [
        DatabaseItem(title: "Información importante", description: "Este texto viene de la base de datos y puede cambiar dinámicamente."),
        DatabaseItem(title: "Actualización reciente", description: "Aquí puedes ver la última actualización registrada en la plataforma."),
        DatabaseItem(title: "Nueva funcionalidad", description: "Ya está disponible la nueva vista de reportes interactivos."),
        DatabaseItem(title: "Mantenimiento programado", description: "El sistema estará en mantenimiento este sábado de 2 a 4 AM.")
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            HStack {
                Text("¡Bienvenido!")
                    .fontWeight(.bold)
                    .font(.system(size: 24))
                    .padding()

                Spacer()

                Image("search")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding()
            }
            .padding(.top)

            CarouselView(items: sampleItems)
                .padding()

            HStack {
                Text("Secciones")
                    .fontWeight(.bold)
                    .font(.system(size: 24))
                    .padding()

                Spacer()
            }

            // Grid de cards
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(databaseItems, id: \.title) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.description)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color(hex: "#F75A13").opacity(0.6))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                }
            }
            .padding([.leading, .trailing])

            Spacer()
        }
    }
}

struct DatabaseItem {
    let title: String
    let description: String
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    HomeView()
}
