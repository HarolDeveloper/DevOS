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

    func clasificarZona(from image: UIImage) {
        zonaClassifier?.clasificar(image: image) { [weak self] resultado in
            DispatchQueue.main.async {
                self?.zonaDetectada = resultado
                print("📍 Zona detectada: \(resultado ?? "Desconocida")")
            }
        }
    }
}
