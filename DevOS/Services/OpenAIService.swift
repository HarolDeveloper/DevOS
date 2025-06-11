//
//  OpenAIService.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 10/06/25.
//


import Foundation
import UIKit

class OpenAIService {
    static let shared = OpenAIService()
    private let apiKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("OPENAI_API_KEY not found in Info.plist")
        }
        return key
    }()

    func generarExplicacionConTextoYImagen(zona: String, descripcion: String, imagen: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = imagen.jpegData(compressionQuality: 0.7)?.base64EncodedString() else {
            print("❌ No se pudo codificar la imagen")
            completion(nil)
            return
        }

        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let base64Image = "data:image/jpeg;base64,\(imageData)"

        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": "Eres un guía turístico del museo. Usa exclusivamente la descripción textual de la zona y la imagen proporcionada para explicar qué se puede observar. No inventes, no digas que no sabes, solo enfócate en describir brevemente lo visible según la zona dada."

            ],
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": "Zona detectada: \(zona).\nDescripción: \(descripcion)"
                    ],
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": base64Image
                        ]
                    ]
                ]
            ]
        ]

        let body: [String: Any] = [
            "model": "gpt-4o",  // ✅ modelo actualizado
            "messages": messages,
            "max_tokens": 300
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Error al serializar JSON: \(error.localizedDescription)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error de red: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No se recibió data")
                completion(nil)
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📦 Respuesta cruda:\n\(rawResponse)")
            }

            do {
                let decoded = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
                let message = decoded.choices.first?.message.content
                completion(message)
            } catch {
                print("❌ Error al decodificar JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}

struct OpenAIChatResponse: Codable {
    struct Choice: Codable {
        let message: Message
    }
    struct Message: Codable {
        let content: String
    }
    let choices: [Choice]
}
