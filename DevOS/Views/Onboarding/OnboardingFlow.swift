//
//  OnboardingFlow.swift
//  DevOS
//
//  Created by Bernardo Caballero on 02/06/25.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var currentPage = 0
    @State private var shouldGoToLogin = false


    // Datos compartidos
    @State private var tipoAcompanantes = ""
    @State private var actividadPreferida = ""
    @State private var deseaShow = false
    @State private var restriccionMayores = false
    @State private var restriccionMovilidad = false
    @State private var restriccionActividadAlta = false
    @State private var intereses: [String] = []
    @State private var selectedTags: Set<String> = []
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showErrorAcompanantes = false
    @State private var showErrorActividad = false
    
    @StateObject var authViewModel = AuthViewModel()
    @StateObject private var preferenciaService = PreferenciaService()
    
    @State private var goToHome = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo naranja
                Color(red: 0.996, green: 0.486, blue: 0.251)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Logo
                    Image("horno3_Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 190)
                        .padding(.top, 20)
                        .padding(.bottom, 50)
                    
                    // Fondo blanco redondeado
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color.white)
                            .ignoresSafeArea(edges: .bottom)
                        
                        VStack(spacing: 0) {
                            // Vistas dentro del flujo
                            TabView(selection: $currentPage) {
                                RestriccionesView(
                                    deseaShow: $deseaShow,
                                    restriccionMayores: $restriccionMayores,
                                    restriccionMovilidad: $restriccionMovilidad,
                                    restriccionActividadAlta: $restriccionActividadAlta
                                )
                                .tag(0)
                                
                                AcompanantesView(
                                    tipoAcompanantes: $tipoAcompanantes,
                                    actividadPreferida: $actividadPreferida,
                                    showErrorAcompanantes: $showErrorAcompanantes,
                                    showErrorActividad: $showErrorActividad,
                                    onNext: { currentPage += 1 }
                                )
                                .tag(1)
                                
                                OnboardingView(
                                    intereses: $intereses,
                                    selectedTags: $selectedTags,
                                    onFinish: {}
                                )
                                .tag(2)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .padding(.top, 40)
                            .padding(.horizontal)
                            
                            // Botón dentro del fondo blanco
                            HStack(spacing: 16) {
                                Button(action: {
                                    if currentPage == 0 {
                                        Task {
                                      
                                            await MainActor.run {
                                                      shouldGoToLogin = true
                                                  }
                                        }
                                        
                                    } else {
                                        currentPage -= 1
                                    }
                                }) {
                                    Text(currentPage == 0 ? "Salir" : "Atrás")
                                        .font(.headline)
                                        .foregroundColor(Color(red: 0.996, green: 0.486, blue: 0.251))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.orange, lineWidth: 2)
                                        )
                                }
                                
                                Button(action: {
                                    if currentPage == 1 {
                                        // Validación
                                        showErrorAcompanantes = tipoAcompanantes.isEmpty
                                        showErrorActividad = actividadPreferida.isEmpty

                                        guard !showErrorAcompanantes, !showErrorActividad else {
                                            return
                                        }
                                        currentPage += 1
                                    } else if currentPage < 2 {
                                        currentPage += 1
                                    } else {
                                        intereses = Array(selectedTags)
                                        Task { await guardarYContinuar() }
                                    }
                                }) {
                                    Text(currentPage < 2 ? "Continuar" : "Empezar")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(red: 0.996, green: 0.486, blue: 0.251))
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                
            }
            
            .navigationDestination(isPresented: $goToHome) {
                NavBarView().navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $shouldGoToLogin) {
                LoginView()
            }


        }
        .onAppear {
            if AuthService.shared.user == nil {
                print("⚠️ No hay usuario, regresando a login")
                shouldGoToLogin = true
            }
        }
    }

    func guardarYContinuar() async {
        guard let userId = AuthService.shared.usuario?.id else {
            print("❌ Usuario no autenticado")
            return
        }
        print(userId)

        let preferencias = PreferenciaVisita(
            usuario_id: userId,
            tipo_acompanantes: tipoAcompanantes,
            actividad_preferida: actividadPreferida,
            desea_show: deseaShow,
            restriccion_mayores: restriccionMayores,
            restriccion_movilidad: restriccionMovilidad,
            restriccion_actividad_alta: restriccionActividadAlta,
            intereses: intereses
        )

        do {
            try await preferenciaService.guardarPreferencias(preferencia: preferencias)
            await MainActor.run {
                authViewModel.markOnboardingCompleted()
                goToHome = true
            }
        } catch {
            print("❌ Error guardando preferencias:", error.localizedDescription)
        }
    }
}

#Preview {
    OnboardingFlowView()
}
