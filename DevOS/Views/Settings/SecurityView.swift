//
//  SecurityView.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 10/06/25.
//


import SwiftUI

struct SecurityView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var newPassword = ""
    @State private var isPasswordVisible = false
    @State private var isSaving = false
    @State private var message: String?
    @State private var emailActual: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Información personal")
                    .font(.headline)
                    .padding(.top)

                VStack(spacing: 16) {
                    // Campo de correo solo lectura
                    TextField("", text: .constant(emailActual))
                        .disabled(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .foregroundColor(.gray)

                    // Campo de contraseña
                    ZStack(alignment: .trailing) {
                        Group {
                            if isPasswordVisible {
                                TextField("Nueva contraseña", text: $newPassword)
                            } else {
                                SecureField("Nueva contraseña", text: $newPassword)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)

                // Botón para guardar
                Button(action: cambiarContrasena) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Guardar cambios")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.996, green: 0.486, blue: 0.251))
                            .cornerRadius(10)
                    }
                }

                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Seguridad")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Atrás")
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            Task {
                do {
                    let session = try await SupabaseManager.shared.client.auth.session
                    let user = session.user
                    emailActual = user.email ?? "Correo no disponible"
                } catch {
                    emailActual = "Error al obtener el correo"
                }
            }
        }
    }

    private func cambiarContrasena() {
        guard !newPassword.isEmpty else {
            message = "La contraseña no puede estar vacía."
            return
        }

        isSaving = true
        message = nil

        Task {
            do {
                try await AuthService.shared.cambiarContrasena(nueva: newPassword)
                message = "✅ Contraseña actualizada correctamente."
                newPassword = ""
            } catch {
                message = "❌ Error al actualizar la contraseña: \(error.localizedDescription)"
            }
            isSaving = false
        }
    }

}

#Preview {
    NavigationView {
        SecurityView()
    }
}
