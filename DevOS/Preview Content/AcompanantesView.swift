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
    @Binding var showErrorAcompanantes: Bool
    @Binding var showErrorActividad: Bool
    var onNext: () -> Void

    let acompanantes = ["familia", "pareja", "solo", "mayores"]
    let actividades = ["baja", "media", "alta"]

    var body: some View {
        VStack(spacing: 30) {
            // Título
            VStack(alignment: .leading, spacing: 6) {
                Text("Acompañantes")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Favor de seleccionar tus acompañantes")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Picker Acompañantes
            VStack(alignment: .leading, spacing: 12) {
                Text("¿Con quién vienes?")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(showErrorAcompanantes ? Color(red: 1.0, green: 0.0588, blue: 0.0588) : .primary)

                Picker("Acompañantes", selection: $tipoAcompanantes) {
                    ForEach(acompanantes, id: \.self) { value in
                        Text(value.capitalized).tag(value)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color.orange)
                .font(.headline)
            }

            // Picker Actividad
            VStack(alignment: .leading, spacing: 12) {
                Text("Nivel de actividad preferido")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(showErrorActividad ? Color(red: 1.0, green: 0.0588, blue: 0.0588) : .primary)

                Picker("Actividad", selection: $actividadPreferida) {
                    ForEach(actividades, id: \.self) { value in
                        Text(value.capitalized).tag(value)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color.orange)
                .font(.headline)
            }

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 10)
    }
}




