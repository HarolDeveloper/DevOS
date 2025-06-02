//
//  AcompanantesView.swift
//  DevOS
//
//  Created by Bernardo Caballero on 02/06/25.
//

import SwiftUI

struct AcompanantesView: View {
    @Binding var tipoAcompanantes: String
    @Binding var actividadPreferida: String
    var onNext: () -> Void

    let acompanantes = ["familia", "pareja", "solo", "mayores"]
    let actividades = ["baja", "media", "alta"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Título
            VStack(alignment: .leading, spacing: 4) {
                Text("Acompañantes")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Favor de seleccionar tus acompañantes")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Picker Acompañantes
            VStack(alignment: .leading, spacing: 8) {
                Text("¿Con quién vienes?")
                    .font(.callout)
                    .foregroundColor(.secondary)

                Picker("Acompañantes", selection: $tipoAcompanantes) {
                    ForEach(acompanantes, id: \.self) { value in
                        Text(value.capitalized).tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Picker Actividad
            VStack(alignment: .leading, spacing: 8) {
                Text("Nivel de actividad preferido")
                    .font(.callout)
                    .foregroundColor(.secondary)

                Picker("Actividad", selection: $actividadPreferida) {
                    ForEach(actividades, id: \.self) { value in
                        Text(value.capitalized).tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 10)
    }
}


#Preview {
    AcompanantesView(
        tipoAcompanantes: .constant("familia"),
        actividadPreferida: .constant("media"),
        onNext: {}
    )
}
