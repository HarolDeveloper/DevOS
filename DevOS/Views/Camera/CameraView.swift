//
//  CameraView.swift
//  DevOS
//
//  Created by Bernardo Caballero on 29/04/25.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var camera = CameraViewModel()
    @State private var showBottomSheet = false

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Button(action: {
                    camera.capturePhoto()
                }) {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.white)
                        .shadow(radius: 8)
                        .padding(.bottom, 30)
                }
            }
        }
        .onChange(of: camera.capturedImage) { _, newValue in
            if let image = newValue {
                showBottomSheet = true
                Task {
                    await camera.clasificarZona(from: image)
                   
                }
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            if let image = camera.capturedImage {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("📸 Foto capturada")
                            .font(.title2)
                            .bold()
                            .padding(.top)

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(16)
                            .shadow(radius: 6)
                            .padding(.horizontal)

                        Divider()

                        if let zona = camera.zonaDetectada {
                            VStack(spacing: 8) {
                                Text("📍 Zona detectada:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                Text(zona)
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        } else {
                            Text("🔍 Detectando zona...")
                                .foregroundColor(.gray)
                        }

                        Divider()

                        if let explicacion = camera.explicacionGenerada {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("🧠 Explicación del guía:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                Text(explicacion)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        } else if camera.zonaDetectada != nil {
                            VStack(spacing: 8) {
                                ProgressView()
                                Text("Generando explicación con IA...")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                            .padding()
                        }

                        Button(action: {
                            showBottomSheet = false
                        }) {
                            Text("Cerrar")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .padding(.top, 16)
                        }
                    }
                }
                .presentationDetents([.large])
                .background(Color(.systemBackground))
            }
        }
    }
}

#Preview {
    CameraView()
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}



let zonaDescriptions: [String: String] = [
    "De la revolución a la recuperación": "Espacio que retrata el impacto de la Revolución Mexicana y la posterior recuperación económica e industrial del país.",
    
    "Electrodomesticos": "Zona interactiva donde se explora la evolución de los electrodomésticos y su impacto en la vida moderna, desde los primeros refrigeradores hasta la automatización actual.",
    
    "Entrada": "Zona de bienvenida al museo, donde los visitantes reciben información general, mapas, boletos y una introducción al recorrido.",
    
    "Galeria de acero": "Vive una experiencia totalmente interactiva, ordenada a través del proceso de producción del acero. En este espacio hay mucho qué explorar: abordar un elevador que los lleva a 200 metros bajo tierra hasta una mina de carbón, o explotar una mina de hierro a cielo abierto. También se pueden disfrutar demostraciones de ciencia en vivo en nuestro Núcleo Científico.",
    
    "Horno 3 por fuera": "Atrévete a subir a las cabinas panorámicas del Paseo por la Cima. ¡Es una aventura de principio a fin! Durante un viaje lento, estas cabinas “abiertas” te permitirán hacer un contacto más cercano con la enorme estructura de acero y descubrir una espectacular panorámica de Monterrey.",
    
    "No Museo": "Este lugar no corresponde a ninguna zona del museo; puede ser una captura externa o irreconocible por el modelo.",
    
    "Raices industriales": "Zona dedicada a los inicios de la industrialización, sus pioneros, primeras fábricas y la transición del campo a la ciudad.",
    
    "Sección Epoca de Oro": "Esta sección destaca el auge industrial del país, mostrando los avances tecnológicos, logros económicos y cambios sociales que marcaron una época próspera.",
    
    "Sección mural": "Zona artística con murales conmemorativos que retratan momentos clave de la historia industrial del país, con estilos variados y gran valor visual.",
    
    "Sección Época de oro parte 2": "Continuación de la muestra del auge industrial con enfoque en la transformación urbana, nuevas tecnologías y cultura popular de la época."
]
