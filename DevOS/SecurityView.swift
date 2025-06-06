import SwiftUI

struct SecurityView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var newPassword = ""
    @State private var isPasswordVisible = false
    @State private var isSaving = false
    @State private var message: String?

    // Simulación del correo actual (reemplázalo con tu modelo real)
    let emailActual = "pruebaemail@gmail.com"

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

                    // Campo de contraseña con opción de mostrar/ocultar
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
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }

                // Mensaje de estado
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
                        Text("Volver")
                    }
                    .foregroundColor(.black)
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
                try await UserAccountService.shared.cambiarContrasena(nueva: newPassword)
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
