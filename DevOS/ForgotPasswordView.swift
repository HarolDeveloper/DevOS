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
        ZStack() {
            
            VStack(spacing: 0) {
                
                VStack(spacing: 20) {
                    Text("Recupera tu contraseña")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Text("Ingresa tu correo electrónico y te enviaremos un código de verificación para restablecer tu contraseña.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 20)
                    
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
                    
                    Spacer()
                }
                .padding(24)
                .background(Color.white)
                
            }
        }
    }
}



#Preview{
    ForgotPasswordView(isPresented: .constant(true))
}
