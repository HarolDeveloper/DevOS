//
//  CameraViewModel.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 14/05/25.
//

import Foundation
import AVFoundation
import UIKit

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let zonaClassifier = ZonaClassifier()
    
    @Published var capturedImage: UIImage?
    @Published var zonaDetectada: String?
    
    @Published var explicacionGenerada: String?
    
    
    override init() {
        super.init()
        configure()
    }
    
    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input),
              session.canAddOutput(output) else {
            print("Error configurando la cámara")
            return
        }
        
        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()
        session.startRunning()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
    

    @MainActor
    func clasificarZona(from image: UIImage) async {
        do {
            let resultado = try await clasificarImagenAsync(image)
            self.zonaDetectada = resultado
            
            if let zona = resultado,
               let descripcion = zonaDescriptions[zona] {
                let explicacion = await generarExplicacionAsync(zona: zona, descripcion: descripcion, imagen: image)
                self.explicacionGenerada = explicacion
                print("🧠 Explicación: \(explicacion ?? "Ninguna")")
            }
        } catch {
            print("Error clasificando zona: \(error)")
        }
    }
    
    private func clasificarImagenAsync(_ image: UIImage) async throws -> String? {
        return await withCheckedContinuation { continuation in
            zonaClassifier?.clasificar(image: image) { resultado in
                continuation.resume(returning: resultado)
            }
        }
    }
    
    private func generarExplicacionAsync(zona: String, descripcion: String, imagen: UIImage) async -> String? {
        return await withCheckedContinuation { continuation in
            OpenAIService.shared.generarExplicacionConTextoYImagen(
                zona: zona,
                descripcion: descripcion,
                imagen: imagen
            ) { explicacion in
                continuation.resume(returning: explicacion)
            }
        }
    }
        

}



