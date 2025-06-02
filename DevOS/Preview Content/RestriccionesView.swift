//
//  RestriccionesView.swift
//  DevOS
//
//  Created by Bernardo Caballero on 02/06/25.
//

import SwiftUI

struct RestriccionesView: View {
    @Binding var deseaShow: Bool
    @Binding var restriccionMayores: Bool
    @Binding var restriccionMovilidad: Bool
    @Binding var restriccionActividadAlta: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Encabezado
            VStack(alignment: .leading, spacing: 4) {
                Text("Restricciones")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Favor de seleccionar tus restricciones")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Toggles
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Quiero asistir al show", isOn: $deseaShow)
                Toggle("Soy mayor de edad", isOn: $restriccionMayores)
                Toggle("Tengo movilidad reducida", isOn: $restriccionMovilidad)
                Toggle("No quiero actividad física alta", isOn: $restriccionActividadAlta)
            }

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 10)
    }
}

#Preview {
    RestriccionesView(
        deseaShow: .constant(true),
        restriccionMayores: .constant(false),
        restriccionMovilidad: .constant(false),
        restriccionActividadAlta: .constant(true)
    )
}
