//
//  SettingsView.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 15/05/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLanguageCode = "es"
    @State private var showingLogoutAlert = false
    @EnvironmentObject var authVM: AuthViewModel
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true

    var body: some View {
        List {
            // MARK: Accesibilidad
            Section(header: Text("accessibility".localized)) {
                Menu {
                    Button("english".localized) {
                        selectedLanguageCode = "en"
                        Bundle.setLanguage("en")
                    }
                    Button("spanish".localized) {
                        selectedLanguageCode = "es"
                        Bundle.setLanguage("es")
                    }
                } label: {
                    HStack {
                        Image(systemName: "globe")
                            .frame(width: 20, height: 20)
                        Text("language".localized)
                        Spacer()
                        Text(
                            selectedLanguageCode == "en"
                                ? "english".localized
                                : "spanish".localized
                        )
                        .foregroundColor(.gray)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }

            // MARK: Privacidad
            Section(header: Text("privacy".localized)) {
                NavigationLink(destination: SecurityView()) {
                    SettingsRow(icon: "lock.shield", title: "security".localized)
                }
            }

            // MARK: Soporte
            Section(header: Text("support".localized)) {
                NavigationLink(destination: FeedbackView()) {
                    SettingsRow(icon: "message", title: "feedback".localized)
                }
            }

            // MARK: Sesión
            Section(header: Text("session".localized)) {
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    SettingsRow(icon: "arrow.backward.circle", title: "logout".localized)
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("logout_title".localized),
                        message: Text("logout_msg".localized),
                        primaryButton: .destructive(Text("logout_confirm".localized)) {
                            Task {
                                await authVM.signOut()
                                isLoggedIn = false
                            }
                        },
                        secondaryButton: .cancel(Text("logout_cancel".localized))
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("settings".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("back".localized)
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
}


// MARK: - Reutilizable fila de configuración
struct SettingsRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20, height: 20)
            Text(title)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
