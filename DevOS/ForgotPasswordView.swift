import SwiftUI

struct ForgotPasswordView: View {
    @Binding var isPresented: Bool
    @State private var email: String
    
    // Initialize with email from login view
    init(isPresented: Binding<Bool>, email: String = "") {
        self._isPresented = isPresented
        self._email = State(initialValue: email)
    }
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer().frame(height: UIScreen.main.bounds.height * 0.2)
                
                VStack(spacing: 32) {
                    Text("Recupera tu contraseña")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                    
                    Text("Ingresa tu correo electrónico y te enviaremos un código de verificación para restablecer tu contraseña.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    
                    TextField("", text: $email)
                        .placeholder(when: email.isEmpty) {
                            Text("Email").foregroundColor(.gray.opacity(0.8))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 0.3)), lineWidth: 1)
                        )
                    
                    // Send Code Button
                    Button(action: {
                        // Lógica para enviar código
                    }) {
                        Text("Enviar código")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
                            .cornerRadius(25)
                    }
                    .padding(.top, 10)
                    
                    // Back to login
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 14))
                            Text("Volver a inicio de sesión")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
                    }
                    .padding(.top, 20)
                }
                .padding(24)
                .frame(height: UIScreen.main.bounds.height / 2)
                
                // Este espaciador ocupará el resto del espacio
                // aproximadamente 1/4 de la pantalla
                Spacer()
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ForgotPasswordView(isPresented: .constant(true))
}
