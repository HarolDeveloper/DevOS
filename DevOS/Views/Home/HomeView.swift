//
//  HomeView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 28/04/25.
//

import SwiftUI

struct HomeView: View {
    @State private var noticias: [Noticia] = []
    @State private var selectedNoticia: Noticia? = nil
    @State private var selectedSectionItem: DatabaseItem? = nil
    @State private var feedbackUsuarioId: UUID? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var showFeedbackSheet = false
    @State private var isSearching: Bool = false
    @State private var isLoadingNoticias = true
    
    @State private var zonas: [Zona] = []
    @State private var isLoadingZonas = true


    let columns = [ GridItem(.flexible()), GridItem(.flexible()) ]

    var body: some View {
            ZStack {
                VStack(spacing: 0) {
                    encabezadoView()

                    ScrollView {
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: geometry.frame(in: .named("scroll")).minY)
                        }
                        .frame(height: 0)

                        VStack(alignment: .leading, spacing: 30) {
                            if isLoadingNoticias {
                                ProgressView("Cargando noticias...")
                                    .frame(height: 150)
                            } else if !noticias.isEmpty {
                                NoticiaCarouselView(noticias: noticias) { noticia in
                                    withAnimation(.spring()) {
                                        selectedNoticia = noticia
                                    }
                                }
                                .padding(.horizontal)
                            }

                            Divider().padding(.horizontal)

                            sectionsGrid()
                            feedbackButton()
                            Spacer()
                        }
                        .padding(.top, 20)
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        scrollOffset = value
                    }
     

                }

                // Overlays para popups
                if let noticia = selectedNoticia {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation { selectedNoticia = nil }
                        }

                    NoticiaPopupView(noticia: noticia) {
                        withAnimation { selectedNoticia = nil }
                    }
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(2)
                }

                if let section = selectedSectionItem {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
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
            .animation(.spring(), value: selectedNoticia)
            .animation(.spring(), value: selectedSectionItem)
            .background(Color.white.ignoresSafeArea())
            .navigationDestination(isPresented: $isSearching) {
                SearchView(isPresented: $isSearching)
            }
            .sheet(isPresented: $showFeedbackSheet) {
                if AuthService.shared.user != nil {
                    FeedbackView()
                } else {
                    LoadingView()
                        .task {
                            if AuthService.shared.user == nil {
                                print("⚠️ No hay usuario logueado.")
                                showFeedbackSheet = false
                            }
                        }
                }
            }.onAppear {
                Task {
                    do {
                        noticias = try await NoticiaService.shared.obtenerNoticias()
                    } catch {
                        print("❌ Error al obtener noticias:", error)
                    }
                    isLoadingNoticias = false

                    do {
                        zonas = try await ZonaService.shared.obtenerTodasZonas()
                    } catch {
                        print("❌ Error al obtener zonas:", error)
                    }
                    isLoadingZonas = false
                }
            }

        }
    

        // MARK: - Encabezado
        @ViewBuilder
        private func encabezadoView() -> some View {
            VStack(spacing: 20) {
                HStack {
                    Text("welcome_title".localized)
                        .fontWeight(.semibold)
                        .font(.system(size: 24))
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image("Settings")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    Text("search_placeholder".localized)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                .onTapGesture {
                    isSearching = true
                }
            }
            .padding(10)
            .background(Color.white)
            .zIndex(1)
        }

        // MARK: - Secciones
    @ViewBuilder
    private func sectionsGrid() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("sections_title".localized)
                .fontWeight(.semibold)
                .font(.system(size: 24))
                .padding(.horizontal)

            if isLoadingZonas {
                ProgressView("loading_sections".localized)
                    .frame(height: 150)
            } else if !zonas.isEmpty {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(zonas) { zona in
                        let item = DatabaseItem(
                            imageName: zona.imageURL ?? "placeholder_zona",
                            title: zona.nombre,
                            description: zona.descripcion 
                        )
                        SectionsItemView(item: item) {
                            withAnimation { selectedSectionItem = item }
                        }
                    }
                }
            } else {
                Text("No hay zonas disponibles.")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
        }
    }


        // MARK: - Botón feedback
        @ViewBuilder
        private func feedbackButton() -> some View {
            Button(action: {
                feedbackUsuarioId = nil
                showFeedbackSheet = true
            }) {
                Text("feedback_button".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.996, green: 0.486, blue: 0.251))
                    .cornerRadius(30)
                    .padding(.horizontal)
            }
        }

        struct ScrollOffsetKey: PreferenceKey {
            static var defaultValue: CGFloat = 0
            static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
                value = nextValue()
            }
        }
    }

#Preview {
    NavigationStack {
        HomeView()
    }
}
