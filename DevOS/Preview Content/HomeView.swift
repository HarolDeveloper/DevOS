import SwiftUI

struct HomeView: View {
    @State private var selectedCarouselItem: CarouselItem? = nil
    @State private var selectedSectionItem: DatabaseItem? = nil
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

    let databaseItems = [
        DatabaseItem(imageName: "escalera", title: "Escaleras caracol", description: "Por aquí se sube al segundo piso del museo."),
        DatabaseItem(imageName: "acero", title: "Museo de acero", description: "Aquí podrás realizar distintas actividaades."),
        DatabaseItem(imageName: "arquitectura", title: "Arquitectura", description: "Algunos de los diseños más sorprendentes del parque."),
        DatabaseItem(imageName: "historia", title: "Museo de historia", description: "Aquí podrás aprender sobre el horno 3.")
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerView()
                    searchBarView()

                    CarouselView(items: sampleItems) { item in
                        selectedCarouselItem = item
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding()

                    sectionsGrid()
                }
            }
            .overlay(
                ZStack {
                    carouselOverlay()
                    sectionOverlay()
                }
            )
            .animation(.spring(), value: selectedCarouselItem)
            .animation(.spring(), value: selectedSectionItem)
            .background(Color.white)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func headerView() -> some View {
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
    }

    @ViewBuilder
    private func searchBarView() -> some View {
        NavigationLink(destination: SearchView(isPresented: $isSearching), isActive: $isSearching) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                Text("¿Qué estás buscando hoy?")
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func sectionsGrid() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Secciones")
                .fontWeight(.semibold)
                .font(.system(size: 24))
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(databaseItems) { item in
                    SectionsItemView(item: item) {
                        withAnimation {
                            selectedSectionItem = item
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func carouselOverlay() -> some View {
        if let selected = selectedCarouselItem {
            Color.black.opacity(0.4)
                
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { selectedCarouselItem = nil }
                }

            CarouselPopupView(item: selected) {
                withAnimation { selectedCarouselItem = nil }
            }
            .transition(.scale.combined(with: .opacity))
            .zIndex(2)
        }
    }

    @ViewBuilder
    private func sectionOverlay() -> some View {
        if let section = selectedSectionItem {
            Color.black.opacity(0.4)
                .ignoresSafeArea() // ✅ moderno y más preciso
                .onTapGesture {
                    withAnimation { selectedSectionItem = nil }
                }

            SectionsPopupView(item: section) {
                withAnimation { selectedSectionItem = nil }
            }
            .transition(.scale.combined(with: .opacity))
            .zIndex(1)
        }
    }
}

#Preview {
    HomeView()
}
