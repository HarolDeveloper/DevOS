import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var rememberMe: Bool = false
    @State private var isShowingRegister: Bool = false
    @State private var slideOffset: CGFloat = 0
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var isShowingForgotPassword: Bool = false
    @State private var navigateToHome: Bool = false
    
    init() {
        // Cargar datos guardados si existen
        _email = State(initialValue: UserDefaults.standard.string(forKey: "savedEmail") ?? "")
        _password = State(initialValue: UserDefaults.standard.string(forKey: "savedPassword") ?? "")
        _rememberMe = State(initialValue: UserDefaults.standard.bool(forKey: "rememberMe"))
    }
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 1.0)))
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                }
                .edgesIgnoringSafeArea(.all)
                mainView
                    .offset(y: isShowingForgotPassword ? UIScreen.main.bounds.height : 0)
                
                if isShowingForgotPassword {
                    ForgotPasswordView(isPresented: $isShowingForgotPassword, email: email)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isShowingForgotPassword)
        }

    }
    
    private var mainView: some View {
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
                .padding(.top, 70)
            
            // Contenedor del formulario
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: isShowingRegister ? UIScreen.main.bounds.height * 0.3425 : UIScreen.main.bounds.height * 0.26)
                
                // Tarjeta blanca con formulario
                VStack(alignment: .leading, spacing: isShowingRegister ? 16 : 20) {
                    ZStack {
                        Text("Log In")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                            .opacity(isShowingRegister ? 0 : 1)
                            .offset(x: slideOffset)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Register")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                            .opacity(isShowingRegister ? 1 : 0)
                            .offset(x: isShowingRegister ? 0 : UIScreen.main.bounds.width)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // Form fields
                    ZStack {
                        VStack(spacing: 20) {
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
                            
                            ZStack(alignment: .trailing) {
                                if isPasswordVisible {
                                    TextField("", text: $password)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Contraseña").foregroundColor(.gray.opacity(0.8))
                                        }
                                        .padding()
                                } else {
                                    SecureField("", text: $password)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Contraseña").foregroundColor(.gray.opacity(0.8))
                                        }
                                        .padding()
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 16)
                            }
                            .background(Color.white)
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 0.3)), lineWidth: 1)
                            )
                            
                            // Remember me y Olvidaste tu contraseña
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
                                    // Mostrar vista de contraseña olvidada
                                    withAnimation {
                                        isShowingForgotPassword = true
                                    }
                                }) {
                                    Text("¿Olvidaste tu contraseña?")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .offset(x: isShowingRegister ? -UIScreen.main.bounds.width : 0)
                        .opacity(isShowingRegister ? 0 : 1)
                        
                        // Register form
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
                            
                            // Password (Register)
                            ZStack(alignment: .trailing) {
                                if isPasswordVisible {
                                    TextField("", text: $password)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Contraseña").foregroundColor(.gray.opacity(0.8))
                                        }
                                        .padding()
                                } else {
                                    SecureField("", text: $password)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Contraseña").foregroundColor(.gray.opacity(0.8))
                                        }
                                        .padding()
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 16)
                            }
                            .background(Color.white)
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color(UIColor(red: 239/255, green: 127/255, blue: 72/255, alpha: 0.3)), lineWidth: 1)
                            )
                            
                            // Confirm Password (Register)
                            ZStack(alignment: .trailing) {
                                if isConfirmPasswordVisible {
                                    TextField("", text: $confirmPassword)
                                        .placeholder(when: confirmPassword.isEmpty) {
                                            Text("Confirma tu contraseña").foregroundColor(.gray.opacity(0.8))
                                        }
                                        .padding()
                                } else {
                                    SecureField("", text: $confirmPassword)
                                        .placeholder(when: confirmPassword.isEmpty) {
                                            Text("Confirma tu contraseña").foregroundColor(.gray.opacity(0.8))
                                        }
                                        .padding()
                                }
                                
                                Button(action: {
                                    isConfirmPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 16)
                            }
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
                    
                    Button(action: {
                        // Lógica de inicio de sesión y registro
                        if rememberMe {
                            saveCredentials()
                        }
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
                    
                    HStack {
                        Text(isShowingRegister ? "¿Ya tienes cuenta?" : "¿No tienes cuenta?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isShowingRegister.toggle()
                                slideOffset = isShowingRegister ? UIScreen.main.bounds.width : 0
                                
                                // Reset password visibility when switching views
                                isPasswordVisible = false
                                isConfirmPasswordVisible = false
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
                    
                    // Sign In with Apple
                    VStack(spacing: 16) { // Añadir spacing para separar los botones
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
                        
                        Button(action: {
                            authFaceID()
                        }) {
                            HStack {
                                Image(systemName: "faceid")
                                    .font(.system(size: 18))
                                    .padding(.trailing, 8)
                                
                                Text(isShowingRegister ? "Registro con Face ID" : "Iniciar sesión con Face ID")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(Color(UIColor.systemBlue))
                            .frame(maxWidth: .infinity)
                            .padding()
                            //.background(Color(UIColor.systemBlue)) // Color azul de sistema para diferenciar
                            .cornerRadius(24)
                        }
                        // Solo mostrar el botón de Face ID en la pantalla de login, no en registro
                        .opacity(isShowingRegister ? 0 : 1)
                        .disabled(isShowingRegister)
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                .animation(.easeInOut(duration: 0.5), value: isShowingRegister)
                .frame(height: isShowingRegister ? 470 : 650)
                
            }
        }
    }
    private func saveCredentials() {
            if rememberMe {
                // Guardar credenciales
                UserDefaults.standard.set(email, forKey: "savedEmail")
                UserDefaults.standard.set(password, forKey: "savedPassword")
                UserDefaults.standard.set(true, forKey: "rememberMe")
            } else {
                // Borrar credenciales guardadas
                UserDefaults.standard.removeObject(forKey: "savedEmail")
                UserDefaults.standard.removeObject(forKey: "savedPassword")
                UserDefaults.standard.set(false, forKey: "rememberMe")
            }
    }
    
    func authFaceID() {
        // Asegurarnos de que estamos en el hilo principal
        DispatchQueue.main.async {
            let context = LAContext()
            var error: NSError?
            
            // Primero verifica si el dispositivo soporta biometría
            if
                context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                let reason = "Iniciar sesión en la aplicación"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("Autenticación exitosa")
                            navigateToHome = true
                        } else {
                            // Manejar el error, pero no abortar la aplicación
                            print("Error")
                            // self.mostrarAlerta("Autenticación fallida", mensaje: "Por favor intenta de nuevo o usa tu contraseña.")
                        }
            }
            
            
            
            
            // Solo intenta autenticar si la biometría está disponible
            
                }
            }
        }
    }

    // Agrega esta función para mostrar alertas en lugar de bloquear la app
    func mostrarAlerta(_ titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        // Para presentar desde SwiftUI, necesitarás usar UIViewControllerRepresentable o
        // En SwiftUI 2.0+, puedes usar .alert() directamente
        // self.present(alerta, animated: true)
    }
}



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
