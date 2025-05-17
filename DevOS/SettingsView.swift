//
//  SettingsView.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 15/05/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedLanguage = "English"
    @State private var showingLogoutAlert = false
    @EnvironmentObject var authVM: AuthViewModel
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true

    var body: some View {
        NavigationView {
            VStack {
                List {
                    // ✅ Selector de idioma con Menu contextual
                    Menu {
                        Button(action: { selectedLanguage = "English" }) {
                            Label("English", systemImage: selectedLanguage == "English" ? "checkmark" : "")
                        }
                        Button(action: { selectedLanguage = "Spanish" }) {
                            Label("Spanish", systemImage: selectedLanguage == "Spanish" ? "checkmark" : "")
                        }
                    } label: {
                        HStack {
                            Text("Language")
                            Spacer()
                            Text(selectedLanguage)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                    }

                    // ✅ Sección de ajustes
                    Section(header: Text("Account Settings")) {
                        NavigationLink(destination: SecurityView()) {
                            SettingsRow(icon: "lock.shield", title: "Security and privacy")
                        }
                        NavigationLink(destination: FeedbackView()) {
                            SettingsRow(icon: "message", title: "Feedback")
                        }
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            SettingsRow(icon: "arrow.backward.circle", title: "Cerrar sesión")
                        }
                        .alert(isPresented: $showingLogoutAlert) {
                            Alert(
                                title: Text("Cerrar sesión"),
                                message: Text("¿Estás seguro que deseas cerrar sesión?"),
                                primaryButton: .destructive(Text("Cerrar sesión")) {
                                    Task {
                                        await authVM.signOut()
                                        isLoggedIn = false
                                    }
                                },
                                secondaryButton: .cancel(Text("Cancelar"))
                            )
                        }
                    }
                }
                .listStyle(.grouped)
                .background(Color.black.edgesIgnoringSafeArea(.all))
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20, height: 20)
            Text(title)
                .font(.body)
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// Dummy views to complete NavigationLinks
struct SecurityView: View {
    var body: some View {
        Text("Security and Privacy Settings")

    }
}

struct FeedbackView: View {
    var body: some View {
        Text("Send Feedback")
    }
}


#Preview {
    SettingsView()
}
