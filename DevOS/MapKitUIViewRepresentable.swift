//
//  MapKitUIViewRepresentable.swift
//  DevOS
//
//  Created by Fernando Rocha on 29/05/25.
//

import SwiftUI
import MapKit
import Foundation

struct NamedPolygon: Identifiable {
    let id = UUID()
    let name: String?
    let polygon: MKPolygon
}

// MARK: - Definición de rutas
struct Route {
    let id: UUID = UUID()
    let name: String
    let experienceIDs: [UUID] // IDs de las experiencias en orden
    let estimatedTime: String
}

// MARK: - Datos de rutas (puedes mover esto a otro archivo)
struct RouteData {
    static let routes: [Route] = [
        Route(
            name: "Ruta Historia y Ciencia",
            experienceIDs: [
                // Aquí van los UUIDs de las experiencias en el orden deseado
                // Ejemplo: UUID de "Galería de historia", UUID de "Reacción en Cadena"
            ],
            estimatedTime: "30 min"
        ),
        // Agrega más rutas aquí
    ]
}

// MARK: - Anotación personalizada
class CustomPointAnnotation: MKPointAnnotation {
    var emoji: String = ""
    var number: String = ""
    var experienceID: UUID?
    var isInActiveRoute: Bool = false
    var routePosition: Int? = nil // Posición en la ruta activa
}

struct MapKitUIViewRepresentable: UIViewRepresentable {
    var region: MKCoordinateRegion
    @Binding var selectedExperienceID: UUID?
    @Binding var activeRoute: Route? // Nueva binding para la ruta activa
    static var namedPolygons: [NamedPolygon] = []

    static func resetPolygons() {
        namedPolygons.removeAll()
    }

    func makeUIView(context: Context) -> MKMapView {
        MapKitUIViewRepresentable.resetPolygons()
        let mapView = MKMapView()
        mapView.setRegion(region, animated: false)
        mapView.delegate = context.coordinator
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.pointOfInterestFilter = .excludingAll
        loadGeoJSON(on: mapView)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Actualizar numeración cuando cambie la ruta activa
        updateAnnotationNumbering(in: uiView)
        
        // Actualizar la selección cuando cambie selectedExperienceID
        if let selectedID = selectedExperienceID {
            selectAnnotation(for: selectedID, in: uiView)
        } else {
            // Deseleccionar todas las anotaciones
            if let selectedAnnotation = uiView.selectedAnnotations.first {
                uiView.deselectAnnotation(selectedAnnotation, animated: true)
            }
        }
    }
    
    private func updateAnnotationNumbering(in mapView: MKMapView) {
        for annotation in mapView.annotations {
            guard let customAnnotation = annotation as? CustomPointAnnotation else { continue }
            
            if let activeRoute = activeRoute,
               let experienceID = customAnnotation.experienceID,
               let routeIndex = activeRoute.experienceIDs.firstIndex(of: experienceID) {
                // Este punto está en la ruta activa
                customAnnotation.isInActiveRoute = true
                customAnnotation.routePosition = routeIndex + 1
                customAnnotation.number = "#\(routeIndex + 1)"
            } else {
                // Este punto no está en la ruta activa
                customAnnotation.isInActiveRoute = false
                customAnnotation.routePosition = nil
                customAnnotation.number = "" // Sin número
            }
        }
        
        // Refrescar las vistas de las anotaciones
        for annotation in mapView.annotations {
            if let annotationView = mapView.view(for: annotation) {
                updateAnnotationView(annotationView, for: annotation as? CustomPointAnnotation)
            }
        }
    }
    
    private func updateAnnotationView(_ annotationView: MKAnnotationView, for customAnnotation: CustomPointAnnotation?) {
        guard let customAnnotation = customAnnotation else { return }
        
        let isSelected = annotationView.isSelected
        let scale: CGFloat = isSelected ? 1.2 : 0.75
        
        annotationView.image = Coordinator.generateEmojiMarkerImage(
            emoji: customAnnotation.emoji,
            number: customAnnotation.number,
            scale: scale,
            isInRoute: customAnnotation.isInActiveRoute
        )
        annotationView.centerOffset = CGPoint(x: 0, y: -46 * scale)
    }
    
    private func selectAnnotation(for experienceID: UUID, in mapView: MKMapView) {
        // Encontrar la anotación correspondiente y seleccionarla
        for annotation in mapView.annotations {
            if let customAnnotation = annotation as? CustomPointAnnotation,
               customAnnotation.experienceID == experienceID {
                mapView.selectAnnotation(customAnnotation, animated: true)
                break
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitUIViewRepresentable
        
        init(_ parent: MapKitUIViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.systemGray5.withAlphaComponent(1)
                renderer.strokeColor = UIColor.systemGray2
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let customAnnotation = annotation as? CustomPointAnnotation else {
                return nil
            }

            let identifier = "customPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            let scale: CGFloat = 0.75
            annotationView?.image = Coordinator.generateEmojiMarkerImage(
                emoji: customAnnotation.emoji,
                number: customAnnotation.number,
                scale: scale,
                isInRoute: customAnnotation.isInActiveRoute
            )
            annotationView?.centerOffset = CGPoint(x: 0, y: -46 * scale)

            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let customAnnotation = view.annotation as? CustomPointAnnotation else { return }
            
            // Actualizar selectedExperienceID cuando se seleccione una anotación en el mapa
            if let experienceID = customAnnotation.experienceID {
                parent.selectedExperienceID = experienceID
            }
            
            let scale: CGFloat = 1.2
            view.image = Coordinator.generateEmojiMarkerImage(
                emoji: customAnnotation.emoji,
                number: customAnnotation.number,
                scale: scale,
                isInRoute: customAnnotation.isInActiveRoute
            )
            view.centerOffset = CGPoint(x: 0, y: -46 * scale)
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            guard let custom = view.annotation as? CustomPointAnnotation else { return }
            let scale: CGFloat = 0.75
            view.image = Coordinator.generateEmojiMarkerImage(
                emoji: custom.emoji,
                number: custom.number,
                scale: scale,
                isInRoute: custom.isInActiveRoute
            )
            view.centerOffset = CGPoint(x: 0, y: -46 * scale)

            parent.selectedExperienceID = nil
        }

        static func generateEmojiMarkerImage(emoji: String, number: String, scale: CGFloat = 1.0, isInRoute: Bool = false) -> UIImage? {
            let baseSize = CGSize(width: 90, height: 93)
            let size = CGSize(width: baseSize.width * scale, height: baseSize.height * scale)
            let renderer = UIGraphicsImageRenderer(size: size)

            return renderer.image { context in
                let ctx = context.cgContext
                ctx.scaleBy(x: scale, y: scale)

                // Color del pin basado en si está en ruta o no
                let pinColor = isInRoute ? UIColor.systemBlue : UIColor.systemGray

                // Fondo del pin (forma personalizada tipo pin)
                let pinPath = UIBezierPath()
                pinPath.move(to: CGPoint(x: 46.644, y: 90.6271))
                pinPath.addLine(to: CGPoint(x: 8.20361, y: 39.889))
                pinPath.addCurve(to: CGPoint(x: 9.8476, y: 36.75),
                                 controlPoint1: CGPoint(x: 7.28465, y: 38.5626),
                                 controlPoint2: CGPoint(x: 8.23396, y: 36.75))
                pinPath.addLine(to: CGPoint(x: 80.1524, y: 36.75))
                pinPath.addCurve(to: CGPoint(x: 81.7964, y: 39.889),
                                 controlPoint1: CGPoint(x: 81.766, y: 36.75),
                                 controlPoint2: CGPoint(x: 82.7153, y: 38.5626))
                pinPath.addLine(to: CGPoint(x: 46.644, y: 90.6271))
                pinPath.close()
                pinColor.setFill()
                pinPath.fill()

                // Círculo del pin
                ctx.setFillColor(pinColor.cgColor)
                ctx.fillEllipse(in: CGRect(x: 5, y: 0, width: 80, height: 80))

                // Forma blanca interior
                let whiteShape = UIBezierPath()
                whiteShape.move(to: CGPoint(x: 46.6326, y: 86.6931))
                whiteShape.addLine(to: CGPoint(x: 9.99387, y: 39.534))
                whiteShape.addCurve(to: CGPoint(x: 11.6264, y: 36.3787),
                                    controlPoint1: CGPoint(x: 9.05648, y: 38.2094),
                                    controlPoint2: CGPoint(x: 10.0037, y: 36.3787))
                whiteShape.addLine(to: CGPoint(x: 78.3736, y: 36.3787))
                whiteShape.addCurve(to: CGPoint(x: 80.0061, y: 39.534),
                                    controlPoint1: CGPoint(x: 79.9963, y: 36.3787),
                                    controlPoint2: CGPoint(x: 80.9435, y: 38.2094))
                whiteShape.addLine(to: CGPoint(x: 46.6326, y: 86.6931))
                whiteShape.close()
                UIColor.white.setFill()
                whiteShape.fill()

                // Círculo blanco interior
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fillEllipse(in: CGRect(x: 6.78, y: 2.0, width: 76.44, height: 74.84))

                // Emoji
                let emojiAttr = NSAttributedString(
                    string: emoji,
                    attributes: [.font: UIFont.systemFont(ofSize: 32)]
                )
                let emojiSize = emojiAttr.size()
                emojiAttr.draw(at: CGPoint(
                    x: (baseSize.width - emojiSize.width) / 2,
                    y: 14
                ))

                // Número (solo si está en ruta y tiene número)
                if isInRoute && !number.isEmpty {
                    let numberAttr = NSAttributedString(
                        string: number,
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                            .foregroundColor: UIColor.darkGray
                        ]
                    )
                    let numberSize = numberAttr.size()
                    numberAttr.draw(at: CGPoint(
                        x: (baseSize.width - numberSize.width) / 2,
                        y: 50
                    ))
                }
            }
        }
    }

    private func loadGeoJSON(on mapView: MKMapView) {
        guard let url = Bundle.main.url(forResource: "horno3", withExtension: "geojson") else { return }

        do {
            let data = try Data(contentsOf: url)
            let features = try MKGeoJSONDecoder().decode(data)

            for feature in features {
                guard let geoFeature = feature as? MKGeoJSONFeature else { continue }

                var name: String? = nil
                if let data = geoFeature.properties,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let firstKey = json.keys.first {
                    name = firstKey
                }

                for geometry in geoFeature.geometry {
                    if let polygon = geometry as? MKPolygon {
                        mapView.addOverlay(polygon, level: .aboveRoads)
                        MapKitUIViewRepresentable.namedPolygons.append(NamedPolygon(name: name, polygon: polygon))
                    } else if let shape = geometry as? MKShape & MKGeoJSONObject {
                        let annotation = CustomPointAnnotation()
                        annotation.coordinate = shape.coordinate
                        annotation.title = name
                        annotation.emoji = emojiFor(name: name)
                        annotation.number = "" // Inicialmente sin número
                        annotation.isInActiveRoute = false
                        
                        // Asignar el experienceID basado en el nombre
                        if let matchedExperience = ExperienceData.all.first(where: {
                            name?.lowercased().contains($0.title.lowercased()) == true
                        }) {
                            annotation.experienceID = matchedExperience.id
                        }
                        
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        } catch {
            print("Error loading GeoJSON: \(error)")
        }
    }

    private func emojiFor(name: String?) -> String {
        guard let name = name?.lowercased() else { return "📍" }
        return ExperienceData.all.first(where: { name.contains($0.title.lowercased()) })?.emoji ?? "📍"
    }
}

// MARK: - Vista SwiftUI para previsualización
struct MapKitUIViewWrapper: View {
    @State private var selectedExperienceID: UUID? = nil
    @State private var activeRoute: Route? = nil
    
    var body: some View {
        VStack {
            MapKitUIViewRepresentable(
                region: MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 25.6763, longitude: -100.2828),
                    span: MKCoordinateSpan(latitudeDelta: 0.0012, longitudeDelta: 0.0012)
                ),
                selectedExperienceID: $selectedExperienceID,
                activeRoute: $activeRoute
            )
            .edgesIgnoringSafeArea(.all)
            
            // Botones de prueba para activar rutas
            HStack {
                Button("Activar Ruta") {
                    activeRoute = RouteData.routes.first
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Limpiar Ruta") {
                    activeRoute = nil
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    MapKitUIViewWrapper()
}
