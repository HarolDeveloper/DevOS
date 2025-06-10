//
//  MapView.swift
//  DevOS
//
//  Created by Fernando Rocha on 29/04/25.
//

import SwiftUI
import MapKit

// MARK: - Models & Environment
public enum BottomSheetDisplayType: Equatable {
    case fraction(CGFloat)
    case minimized
}

private struct DisplayTypeKey: EnvironmentKey {
    static let defaultValue: Binding<BottomSheetDisplayType> = .constant(.minimized)
}

extension EnvironmentValues {
    var displayType: Binding<BottomSheetDisplayType> {
        get { self[DisplayTypeKey.self] }
        set { self[DisplayTypeKey.self] = newValue }
    }
}

// MARK: - Supporting Views
struct DragToExpandWrapper<Content: View>: View {
    @Environment(\.displayType) private var displayTypeBinding
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 5, coordinateSpace: .local)
                    .onChanged { _ in
                        displayTypeBinding.wrappedValue = .fraction(0.4)
                    }
            )
    }
}

struct PlanVisitButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Planear visita")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(20)
        }
        .shadow(radius: 4)
    }
}

struct ExperienceScrollView: View {
    let experiences: [Experience]
    @Binding var selectedExperienceID: UUID?
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(experiences) { experience in
                    ExperienceRowView(
                        experience: experience,
                        isSelected: selectedExperienceID == experience.id
                    ) {
                        selectedExperienceID = experience.id
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ExperienceListView: View {
    let experiences: [Experience]
    @Binding var selectedExperienceID: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Secciones")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
                .padding(.top, 10)
            
            ExperienceScrollView(
                experiences: experiences,
                selectedExperienceID: $selectedExperienceID
            )
        }
    }
}

struct ExperienceRowView: View {
    let experience: Experience
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(experience.emoji)
                    .font(.system(size: 22))
                Text(experience.title)
                    .font(.system(size: 22, weight: .bold))
                Spacer()
            }
            .padding()
            .background(isSelected ? Color(red: 0.992, green: 0.812, blue: 0.729) : .clear)
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }
}

struct MinimizedExperienceView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Secciones")
                .font(.title)
                .foregroundColor(.gray)
                .padding()
            
            DragToExpandWrapper {
                Color.clear.frame(height: 1)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Spacer()
        }
    }
}

struct RouteCardsScrollView: View {
    let rutaSugerida: [Zona]
    @Binding var selectedExperienceID: UUID? // Agregar binding
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(rutaSugerida.enumerated()), id: \.element.id) { index, zona in
                    // Buscar la experiencia correspondiente a esta zona
                    if let experience = ExperienceData.all.first(where: { experience in
                        zona.nombre.lowercased().contains(experience.title.lowercased()) ||
                        experience.title.lowercased().contains(zona.nombre.lowercased())
                    }) {
                        RouteCardView(
                            number: "#\(index + 1)",
                            title: zona.nombre,
                            emoji: experience.emoji,
                            imageURL: zona.imageURL,
                            isSelected: selectedExperienceID == experience.id,
                            onTap: {
                                selectedExperienceID = experience.id
                            }
                        )
                    } else {
                        RouteCardView(
                            number: "#\(index + 1)",
                            title: zona.nombre,
                            emoji: "📍", // Emoji por defecto
                            imageURL: zona.imageURL,
                            isSelected: false,
                            onTap: nil
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct RouteControlsView: View {
    let estimatedTime: String
    let onExit: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onExit) {
                Text("Salir")
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(Color.red)
                    .cornerRadius(14)
            }
            
            Spacer()
            
            EstimatedTimeView(estimatedTime: estimatedTime)
        }
        .padding(.horizontal)
    }
}

struct RouteView: View {
    let rutaSugerida: [Zona]
    let estimatedTime: String
    @Binding var selectedExperienceID: UUID? // Agregar binding
    let onExit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("¡Sigue esta ruta!")
                .font(.title2)
                .bold()
            
            RouteCardsScrollView(
                rutaSugerida: rutaSugerida,
                selectedExperienceID: $selectedExperienceID // Pasar el binding
            )
            
            RouteControlsView(estimatedTime: estimatedTime, onExit: onExit)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .safeAreaInset(edge: .bottom) {
            // Espacio para el navbar
            Color.clear.frame(height: 20)
        }
    }
}

struct MinimizedRouteView: View {
    let estimatedTime: String
    
    var body: some View {
        VStack(spacing: 16) {
            EstimatedTimeView(estimatedTime: estimatedTime)
                .font(.title)
                .foregroundColor(.gray)
                .padding()
            
            DragToExpandWrapper {
                Color.clear.frame(height: 1)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Spacer()
        }
    }
}

struct EstimatedTimeView: View {
    let estimatedTime: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text("Tiempo estimado")
            Circle().frame(width: 6, height: 6)
            Text(estimatedTime).bold()
        }
        .font(.subheadline)
        .foregroundColor(.gray)
    }
}

// MARK: - MapView ViewModel
@MainActor
class MapViewModel: ObservableObject {
    @Published var selectedExperienceID: UUID?
    @Published var showPlanner = false
    @Published var showRoute = false
    @Published var estimatedTime = "30 min"
    @Published var displayType: BottomSheetDisplayType = .minimized
    @Published var routeDisplayType: BottomSheetDisplayType = .fraction(0.55)
    @Published var rutaSugerida: [Zona] = []
    @Published var activeRoute: Route? = nil // Nueva propiedad para la ruta activa
    
    var filteredExperiences: [Experience] {
        ExperienceData.all
    }
    
    func showPlannerView() {
        showPlanner = true
    }
    
    func exitRoute() {
        showRoute = false
        activeRoute = nil // Limpiar la ruta activa al salir
        displayType = .fraction(0.4)
    }
    
    func calculateRoute(for visita: Visita, userId: UUID) {
        Task {
            do {
                let zonas = try await ZonaService.shared.obtenerTodasZonas()
                let preferencias = try await PreferenciaService().obtenerPorUsuario(userId: userId.uuidString)
                let ruta = calcularRutaOptima(zonas: zonas, visita: visita, preferencias: preferencias)
                
                await MainActor.run {
                    self.rutaSugerida = ruta
                    // Crear la ruta activa basada en las zonas calculadas
                    self.createActiveRoute(from: ruta)
                }
            } catch {
                print("❌ Error al calcular ruta:", error)
            }
        }
    }
    
    // Función para crear una ruta activa basada en las zonas calculadas
    private func createActiveRoute(from zonas: [Zona]) {
        // Mapear las zonas a experienceIDs
        let experienceIDs = zonas.compactMap { zona -> UUID? in
            // Buscar la experiencia que corresponde a esta zona
            return ExperienceData.all.first { experience in
                zona.nombre.lowercased().contains(experience.title.lowercased()) ||
                experience.title.lowercased().contains(zona.nombre.lowercased())
            }?.id
        }
        
        if !experienceIDs.isEmpty {
            activeRoute = Route(
                name: "Ruta Calculada",
                experienceIDs: experienceIDs,
                estimatedTime: estimatedTime
            )
        }
    }
}

// MARK: - Main MapView
struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.6763, longitude: -100.2828),
            span: MKCoordinateSpan(latitudeDelta: 0.0012, longitudeDelta: 0.0012)
        )
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Map
            MapKitUIViewRepresentable(
                region: mapRegion,
                selectedExperienceID: $viewModel.selectedExperienceID,
                activeRoute: $viewModel.activeRoute // Agregar el parámetro que faltaba
            )
            .edgesIgnoringSafeArea(.all)
            
            // Plan Visit Button
            if !viewModel.showRoute {
                PlanVisitButton {
                    viewModel.showPlannerView()
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
            }
            
            // Experience Bottom Sheet
            if !viewModel.showRoute {
                BottomSheetAdvanceView(displayType: $viewModel.displayType, buttonFrame: .zero) {
                    if case .fraction = viewModel.displayType {
                        ExperienceListView(
                            experiences: viewModel.filteredExperiences,
                            selectedExperienceID: $viewModel.selectedExperienceID
                        )
                    } else {
                        MinimizedExperienceView()
                    }
                }
            }
            
            // Route Bottom Sheet
            if viewModel.showRoute {
                BottomSheetAdvanceView(displayType: $viewModel.routeDisplayType, buttonFrame: .zero) {
                    if case .fraction = viewModel.routeDisplayType {
                        RouteView(
                            rutaSugerida: viewModel.rutaSugerida,
                            estimatedTime: viewModel.estimatedTime,
                            selectedExperienceID: $viewModel.selectedExperienceID, // Pasar el binding
                            onExit: viewModel.exitRoute
                        )
                    } else {
                        MinimizedRouteView(estimatedTime: viewModel.estimatedTime)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showPlanner) {
            VisitPlannerSheetView(
                showRouteSheet: $viewModel.showRoute,
                estimatedTime: $viewModel.estimatedTime,
                onRutaCalculada: viewModel.calculateRoute
            )
        }
        .onAppear {
            viewModel.routeDisplayType = .fraction(0.55)
        }
    }
}

// MARK: - Visit Planner Sheet
struct VisitPlannerSheetView: View {
    @Binding var showRouteSheet: Bool
    @Binding var estimatedTime: String
    let onRutaCalculada: (Visita, UUID) -> Void
    
    var body: some View {
        Group {
            if let user = SupabaseManager.shared.client.auth.currentUser {
                VisitPlannerView(
                    showRouteSheet: $showRouteSheet,
                    estimatedTime: $estimatedTime,
                    usuarioId: user.id,
                    onRutaCalculada: { visita in
                        onRutaCalculada(visita, user.id)
                    }
                )
            } else {
                Text("Usuario no autenticado")
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - BottomSheet Constants
fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 5
    static let indicatorWidth: CGFloat = 40
    static let minHeight: CGFloat = 120
}

// MARK: - BottomSheet Component
struct BottomSheetAdvanceView<Content: View>: View {
    @Binding var displayType: BottomSheetDisplayType
    let buttonFrame: CGRect
    let content: Content
    @GestureState private var translation: CGFloat = 0
    @State private var allowDrag = true

    init(displayType: Binding<BottomSheetDisplayType>, buttonFrame: CGRect, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._displayType = displayType
        self.buttonFrame = buttonFrame
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(width: Constants.indicatorWidth, height: Constants.indicatorHeight)
    }

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let minHeight = Constants.minHeight
            
            let totalHeight: CGFloat = {
                switch displayType {
                case .fraction(let value):
                    return screenHeight * value
                case .minimized:
                    return minHeight
                }
            }()
            
            let offset: CGFloat = {
                switch displayType {
                case .fraction(let value):
                    return screenHeight - (screenHeight * value)
                case .minimized:
                    return screenHeight - minHeight
                }
            }()

            VStack(spacing: 0) {
                indicator
                    .padding(.vertical, 8)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Spacer extra para cubrir el área cuando se estira
                Spacer(minLength: screenHeight)
                    .background(Color(.secondarySystemBackground))
            }
            .frame(width: geometry.size.width, height: totalHeight + screenHeight, alignment: .top)
            .background(Color(.secondarySystemBackground))
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: Constants.radius, topTrailingRadius: Constants.radius))
            .offset(y: offset + translation)
            .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8), value: displayType)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        allowDrag = !buttonFrame.contains(value.startLocation)
                    }
                    .updating($translation) { value, state, _ in
                        if allowDrag {
                            state = value.translation.height
                        }
                    }
                    .onEnded { value in
                        guard allowDrag else { return }
                        let velocity = value.predictedEndLocation.y - value.location.y
                        let translation = value.translation.height
                        if translation < -50 || velocity < -200 {
                            displayType = .fraction(0.55)
                        } else {
                            displayType = .minimized
                        }
                    }
            )
            .environment(\.displayType, $displayType)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Preview
#Preview {
    MapView()
}
