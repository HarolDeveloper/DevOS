//
//  OnboardingFlow.swift
//  DevOS
//
//  Created by Bernardo Caballero on 02/06/25.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var currentPage = 0

    // Datos compartidos
    @State private var tipoAcompanantes = ""
    @State private var actividadPreferida = ""
    @State private var deseaShow = false
    @State private var restriccionMayores = false
    @State private var restriccionMovilidad = false
    @State private var restriccionActividadAlta = false
    @State private var intereses: [String] = []
    @State private var selectedTags: Set<String> = []
    
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
                            Button(action: {
                                if currentPage < 2 {
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
                                    .background(Color.orange)
                                    .cornerRadius(20)
                                    .padding(.horizontal, 30)
                                    .padding(.bottom, 30)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationDestination(isPresented: $goToHome) {
                NavBarView().navigationBarBackButtonHidden(true)
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
