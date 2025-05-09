import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var rememberMe: Bool = false
    
    // State to track whether we're showing login or registration view
    @State private var isShowingRegister: Bool = false
    
    // State for animation offset
    @State private var slideOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                
                
            }
            .edgesIgnoringSafeArea(.all)
            
            Image("horno3-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .padding(.top, 50)
            
            // Contenedor del formulario
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: isShowingRegister ? UIScreen.main.bounds.height * 0.343 : UIScreen.main.bounds.height * 0.31)
                
                // Tarjeta blanca con formulario - spacing adaptativo
                VStack(alignment: .leading, spacing: isShowingRegister ? 16 : 20) {
                    // Título animado
                    ZStack {
                        // Login Title
                        Text("Log In")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                            .opacity(isShowingRegister ? 0 : 1)
                            .offset(x: slideOffset)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Register Title
                        Text("Register")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                            .opacity(isShowingRegister ? 1 : 0)
                            .offset(x: isShowingRegister ? 0 : UIScreen.main.bounds.width)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // Form fields group
                    ZStack {
                        // Login form
                        VStack(spacing: 20) {
                            // Email TextField
                            TextField("", text: $email)
                                .placeholder(when: email.isEmpty) {
                                    Text("Email o nombre de usuario").foregroundColor(.gray.opacity(0.8))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 0.3)), lineWidth: 1)
                                )
                            
                            // Password TextField
                            SecureField("", text: $password)
                                .placeholder(when: password.isEmpty) {
                                    Text("Contraseña").foregroundColor(.gray.opacity(0.8))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 0.3)), lineWidth: 1)
                                )
                            
                            // Remember me y ¿Olvidaste tu contraseña?
                            HStack {
                                Button(action: {
                                    rememberMe.toggle()
                                }) {
                                    HStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(rememberMe ? Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)) : Color.clear)
                                                .frame(width: 22, height: 22)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)), lineWidth: 2)
                                                )
                                            
                                            if rememberMe {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        
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
                        }
                        .offset(x: isShowingRegister ? -UIScreen.main.bounds.width : 0)
                        .opacity(isShowingRegister ? 0 : 1)
                        
                        // Register form (more compact)
                        VStack(spacing: 16) {
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
                            
                            // Password TextField (Register)
                            SecureField("", text: $password)
                                .placeholder(when: password.isEmpty) {
                                    Text("Contraseña").foregroundColor(.gray.opacity(0.8))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 0.3)), lineWidth: 1)
                                )
                            
                            // Confirm Password TextField (Register)
                            SecureField("", text: $confirmPassword)
                                .placeholder(when: confirmPassword.isEmpty) {
                                    Text("Confirma tu contraseña").foregroundColor(.gray.opacity(0.8))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 0.3)), lineWidth: 1)
                                )
                        }
                        .offset(x: isShowingRegister ? 0 : UIScreen.main.bounds.width)
                        .opacity(isShowingRegister ? 1 : 0)
                    }
                    
                    // Action Button
                    Button(action: {
                        // Lógica de inicio de sesión o registro
                    }) {
                        Text(isShowingRegister ? "Register" : "Sign In")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
                            .cornerRadius(25)
                    }
                    .padding(.top, 10)
                    
                    // No tienes cuenta / Ya tienes cuenta
                    HStack {
                        Text(isShowingRegister ? "¿Ya tienes cuenta?" : "¿No tienes cuenta?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            // Transición animada entre login y registro
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isShowingRegister.toggle()
                                slideOffset = isShowingRegister ? UIScreen.main.bounds.width : 0
                            }
                        }) {
                            Text(isShowingRegister ? "Inicia sesión" : "Crea tu cuenta")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
                        }
                    }
                    .padding(.top, 10)
                    
                    
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Circle()
                                .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                                .background(Circle().fill(.white))
                                .frame(width: 16, height: 16)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .padding()
                        
                        // Sign In with Apple (solo en login view)
                        Button(action: {
                            // Lógica de inicio de sesión con Apple
                        }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 18))
                                    .padding(.trailing, 8)
                                
                                Text(isShowingRegister ? "Register with Apple" : "Sign In with Apple")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(24)
                        }
                    
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                .animation(.easeInOut(duration: 0.5), value: isShowingRegister)
                .frame(height: isShowingRegister ? 470 : 550)
            }
        }
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

// Extension para aplicar border radius solo a ciertas esquinas
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview{
    LoginView()
}
