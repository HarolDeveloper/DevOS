//
//  FeedbackView.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 29/05/25.
//

import SwiftUI
import Supabase

struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var rating: Int = 0
    @State private var message: String = ""
    @State private var isSending = false
    @State private var showConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let maxCharacters = 500

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("feedback_title".localized)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 16)

                // Estrellas de calificación
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.orange)
                            .onTapGesture {
                                rating = star
                            }
                    }
                }

                // Campo de texto con contador
                VStack(alignment: .leading, spacing: 8) {
                    Text("feedback_message".localized)
                        .font(.headline)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                            .frame(minHeight: 160)

                        TextEditor(text: $message)
                            .padding(12)
                            .frame(height: 160)
                            .onChange(of: message) { newValue in
                                if newValue.count > maxCharacters {
                                    message = String(newValue.prefix(maxCharacters))
                                }
                            }
                    }

                    HStack {
                        Spacer()
                        Text("\(message.count)/\(maxCharacters)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // Botón de envío
                Button(action: {
                    Task {
                        isSending = true
                        do {
                            guard let userId = AuthService.shared.user?.id.uuidString else {
                                throw NSError(domain: "Feedback", code: 401, userInfo: [NSLocalizedDescriptionKey: "No se encontró sesión activa del usuario."])
                            }

                            try await ReviewService.shared.crearReview(
                                usuarioId: userId,
                                contenido: message,
                                calificacion: rating
                            )

                            showConfirmation = true
                            message = ""
                            rating = 0
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                        isSending = false
                    }
                }) {
                    if isSending {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(12)
                    } else {
                        Text("feedback_send".localized)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((rating > 0 && !message.isEmpty) ? Color.orange : Color.gray)
                            .cornerRadius(12)
                    }
                }
                .disabled(rating == 0 || message.isEmpty)


                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("feedback".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("¡Gracias por tu feedback!", isPresented: $showConfirmation) {
            Button("Cerrar") { presentationMode.wrappedValue.dismiss() }
        }
        .alert("Error", isPresented: $showError) {
            Button("Cerrar", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}
