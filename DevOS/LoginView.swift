import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo
            VStack {
                Image("horno3-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .background(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
            
            
            // Contenido principal
            VStack(alignment: .leading, spacing: 24) {
                // Título
                Text("Log In")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // Email TextField
                TextField("", text: $email)
                    .placeholder(when: email.isEmpty) {
                        Text("Email o nombre de usuario").foregroundColor(.gray.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Password TextField
                SecureField("", text: $password)
                    .placeholder(when: password.isEmpty) {
                        Text("Contraseña").foregroundColor(.gray.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Remember me y ¿Olvidaste tu contraseña?
                HStack {
                    Button(action: {
                        rememberMe.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
                            
                            Text("Remember me")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Lógica para recuperar contraseña
                    }) {
                        Text("¿Olvidaste tu contraseña?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                // Sign In Button
                Button(action: {
                    // Lógica de inicio de sesión
                }) {
                    Text("Sign In")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
                        .cornerRadius(24)
                }
                .padding(.top, 10)
                
                // No tienes cuenta
                HStack{
                    Text("¿No tienes cuenta?")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    
                    Button(action: {
                        // Navegación a registro
                    }) {
                        Text("Crea tu cuenta")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
                    }
                    
                }
                .padding(.top, 10)
                
                // Separador
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                        .background(Circle().fill(.white))
                        .frame(width: 24, height: 24)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.vertical, 24)
                
                // Sign In with Apple
                Button(action: {
                    // Lógica de inicio de sesión con Apple
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18))
                        
                        Text("Sign In with Apple")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(24)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(Color.white)
        }
        .background(Color.gray.opacity(0.1))
        
    }
}

// Extension para crear placeholder en TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
