import SwiftUI

struct HomeView: View {
    @State private var noticias: [Noticia] = []
    @State private var selectedNoticia: Noticia? = nil
    @State private var selectedSectionItem: DatabaseItem? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var showFeedbackSheet = false
    @State private var isSearching: Bool = false
    @State private var isLoadingNoticias = true

    let databaseItems = [
        DatabaseItem(imageName: "galeria_historia", title: "Galería de la historia", description: "Viaja a través del tiempo y descubre los hechos que forjaron la industria de nuestro país y su relación con los acontecimientos en el resto del mundo. De 1900 a la actualidad, encuentra detalles fascinantes, vídeos históricos, testimonios de ex trabajadores de la industria, artefactos antiguos y mucho más."),
        
        DatabaseItem(imageName: "galeria_acero", title: "Galería del acero", description: "Vive una experiencia totalmente interactiva, ordenada a través del proceso de producción del acero. En este espacio hay mucho qué explorar: abordar un elevador que los lleva a 200 metros bajo tierra hasta una mina de carbón, o explotar una mina de hierro a cielo abierto. También se pueden disfrutar demostraciones de ciencia en vivo en nuestro Núcleo Científico."),
        
        DatabaseItem(imageName: "show_horno", title: "Show del horno", description: "Déjate envolver por este magnífico espectáculo que sucede en la antigua Casa de Vaciados, el corazón de la fundición. Mediante vapor, humo, fuego real y chispas, te brindaremos la oportunidad de vivir una experiencia única e inolvidable. Además, podrás entrar en contacto al conocer el interior del Horno Alto No.3, una experiencia única en el mundo."),
        
        DatabaseItem(imageName: "paseo_cima", title: "Paseo por la cima", description: "Atrévete a subir a las cabinas panorámicas del Paseo por la Cima. ¡Es una aventura de principio a fin! Durante un viaje lento, estas cabinas “abiertas” te permitirán hacer un contacto más cercano con la enorme estructura de acero y descubrir una espectacular panorámica de Monterrey, a medida que asciendes los 40 metros del trayecto. "),
        
        DatabaseItem(imageName: "planeta_tierra", title: "Planeta tierra", description: "Adentrate a un espacio de contemplación único en el mundo. Aquí podrás observar fenómenos meteorológicos como huracanes, terremotos, tsunamis, conocer más sobre el cambio climático y descubrir datos científicos de nuestro planeta que te impactarán. Ubicado en el Colector de Polvos del Antiguo Horno Alto No.3, horno³, Planeta Tierra es un espacio que nace gracias al patrocinio de GRUMA, una empresa socialmente responsable."),
        
        DatabaseItem(imageName: "reaccion_cadena", title: "Reacción en cadena", description: "Explora nuestra nueva instalación permanente en el lobby del museo. Esta innovadora atracción visualiza cómo simples acciones desencadenan eventos complejos, utilizando objetos comunes para explicar principios de física, ingeniería y matemáticas. Observa de cerca el movimiento de engranajes, poleas y catapultas, y descubre la ciencia en los detalles más sorprendentes.")
    ]

    let columns = [ GridItem(.flexible()), GridItem(.flexible()) ]

        var body: some View {
            NavigationStack {
                ZStack(alignment: .top) {
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
                                    selectedNoticia = noticia
                                }
                                .padding(.horizontal)
                            }

                            Divider().padding(.horizontal)

                            sectionsGrid()
                            feedbackButton()
                            Spacer()
                        }
                        .padding(.top, 115)
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        scrollOffset = value
                    }
                    .scrollIndicators(.hidden)
                    .onAppear {
                        Task {
                            do {
                                noticias = try await NoticiaService.shared.obtenerNoticias()
                            } catch {
                                print("❌ Error al obtener noticias:", error)
                            }
                            isLoadingNoticias = false
                        }
                    }

                    VStack(spacing: 20) {
                        HStack {
                            Text("¡Bienvenido!")
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
                            Text("¿Qué estás buscando hoy?")
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

                    ZStack {
                        noticiaOverlay()
                        sectionOverlay()
                    }
                }
                .animation(.spring(), value: selectedNoticia?.id)
                .animation(.spring(), value: selectedSectionItem)
                .background(Color.white.ignoresSafeArea(.all, edges: .top))
                .navigationDestination(isPresented: $isSearching) {
                    SearchView(isPresented: $isSearching)
                }
            }
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
        private func feedbackButton() -> some View {
            Button(action: {
                showFeedbackSheet = true
            }) {
                Text("¿Tienes comentarios?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.996, green: 0.486, blue: 0.251))
                    .cornerRadius(30)
                    .padding(.horizontal)
            }
            .sheet(isPresented: $showFeedbackSheet) {
                FeedbackView()
            }
        }

        @ViewBuilder
        private func noticiaOverlay() -> some View {
            if let noticia = selectedNoticia {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { selectedNoticia = nil }
                    }

                NoticiaPopupView(noticia: noticia) {
                    withAnimation { selectedNoticia = nil }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
        }

        @ViewBuilder
        private func sectionOverlay() -> some View {
            if let section = selectedSectionItem {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
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

        struct ScrollOffsetKey: PreferenceKey {
            static var defaultValue: CGFloat = 0
            static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
                value = nextValue()
            }
        }
    }

    #Preview {
        HomeView()
    }
