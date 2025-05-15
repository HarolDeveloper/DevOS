//
//  ZonaClassifier.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 14/05/25.
//

import CoreML
import Vision
import UIKit

class ZonaClassifier {
    private let model: VNCoreMLModel

    init?() {
        guard let mlModel = try? MyWalletClassifier(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: mlModel) else {
            print("❌ Error cargando el modelo")
            return nil
        }

        self.model = visionModel
    }

    func clasificar(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }

        let request = VNCoreMLRequest(model: model) { request, _ in
            if let result = (request.results as? [VNClassificationObservation])?.first {
                completion(result.identifier)
            } else {
                completion(nil)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        try? handler.perform([request])
    }
}
