//
//  MapView.swift
//  DevOS
//
//  Created by Fernando Rocha on 29/04/25.
//

import SwiftUI
import MapKit

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

struct MapView: View {
    @State private var selectedExperienceID: UUID? = nil
    @State private var showPlanner = false
    @State private var showRoute = false
    @State private var estimatedTime = "30 min"
    @State private var displayType: BottomSheetDisplayType = .minimized
    @State private var routeDisplayType: BottomSheetDisplayType = .fraction(0.4)
    @State private var rutaSugerida: [Zona] = []

    var filteredExperiences: [Experience] {
        ExperienceData.all
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapKitUIViewRepresentable(
                region: MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 25.6763, longitude: -100.2828),
                    span: MKCoordinateSpan(latitudeDelta: 0.0012, longitudeDelta: 0.0012)
                ),
                selectedExperienceID: $selectedExperienceID
            )
            .edgesIgnoringSafeArea(.all)

            if !showRoute {
                Button(action: {
                    showPlanner = true
                }) {
                    Text("Planear visita")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
                .shadow(radius: 4)
            }

            if !showRoute {
                BottomSheetAdvanceView(displayType: $displayType, buttonFrame: .zero) {
                    if case .fraction = displayType {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Secciones")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.top, 10)
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 16) {
                                    ForEach(filteredExperiences) { experience in
                                        Button {
                                            selectedExperienceID = experience.id
                                        } label: {
                                            HStack {
                                                Text(experience.emoji)
                                                    .font(.system(size: 22))
                                                Text(experience.title)
                                                    .font(.system(size: 22, weight: .bold))
                                                Spacer()
                                            }
                                            .padding()
                                            .background(selectedExperienceID == experience.id ? Color(red: 0.992, green: 0.812, blue: 0.729) : .clear)
                                            .cornerRadius(12)
                                        }
                                        .foregroundColor(.primary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .padding(.bottom, 40)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
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
            }

            if showRoute {
                BottomSheetAdvanceView(displayType: $routeDisplayType, buttonFrame: .zero) {
                    if case .fraction = routeDisplayType {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("¡Sigue esta ruta!")
                                .font(.title2)
                                .bold()

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(Array(rutaSugerida.enumerated()), id: \.element.id) { index, zona in
                                        RouteCardView(
                                            number: "#\(index + 1)",
                                            title: zona.nombre,
                                            image: "photo" // Reemplaza con imagen si tienes una real
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }

                            HStack {
                                Button(action: {
                                    showRoute = false
                                    displayType = .fraction(0.4)
                                }) {
                                    Text("Salir")
                                        .foregroundColor(.white)
                                        .frame(width: 120, height: 44)
                                        .background(Color.red)
                                        .cornerRadius(14)
                                }

                                Spacer()

                                HStack(spacing: 6) {
                                    Text("Tiempo estimado")
                                    Circle().frame(width: 6, height: 6)
                                    Text(estimatedTime).bold()
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                            .padding(.horizontal)

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    } else {
                        VStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Text("Tiempo estimado")
                                Circle().frame(width: 6, height: 6)
                                Text(estimatedTime).bold()
                            }
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
            }
        }
        .sheet(isPresented: $showPlanner) {
            VisitPlannerView(
                showRouteSheet: $showRoute,
                estimatedTime: $estimatedTime,
                usuarioId: UUID(),
                onRutaCalculada: { visita in
                    Task {
                        do {
                            let zonas = try await ZonaService.shared.obtenerTodasZonas()
                            let preferencias = try await PreferenciaService.shared.obtenerPorUsuario(visita.usuario_id)
                            let ruta = calcularRutaOptima(zonas: zonas, visita: visita, preferencias: preferencias)
                            self.rutaSugerida = ruta
                        } catch {
                            print("❌ Error al calcular ruta:", error)
                        }
                    }
                }
            )
        }
        .onAppear {
            routeDisplayType = .fraction(0.4)
        }
    }
}

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 5
    static let indicatorWidth: CGFloat = 40
    static let minHeight: CGFloat = 120
}


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
            let maxHeight = screenHeight * 0.85
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
                            displayType = .fraction(0.4)
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
