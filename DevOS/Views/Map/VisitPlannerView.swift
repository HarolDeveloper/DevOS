//
//  VisitPlannerView.swift
//  DevOS
//
//  Created by Fernando Rocha on 05/06/25.
//

import SwiftUI

// MARK: - Modelos para la Base de Datos
struct VisitaDB: Codable {
    let id: UUID
    let usuario_id: UUID
    let dia_visita: String // Formato: "martes", "miércoles", etc.
    let hora_inicio_visita: String // Formato: "HH:MM:SS"
    let tiempo_disponible: Int // En minutos
    // fecha_creacion se genera automáticamente en la DB, no la incluimos
}

// MARK: - Servicio para manejar visitas
class VisitaService {
    static let shared = VisitaService()
    private init() {}
    
    func crearVisita(_ visita: VisitaDB) async throws {
        do {
            print("🔍 Intentando insertar en DB:")
            print("   ID: \(visita.id)")
            print("   Usuario ID: \(visita.usuario_id)")
            print("   Día visita: \(visita.dia_visita)")
            print("   Hora inicio: \(visita.hora_inicio_visita)")
            print("   Tiempo disponible: \(visita.tiempo_disponible)")
            
            let _ = try await SupabaseManager.shared.client
                .from("visita")
                .insert(visita)
                .execute()
            
            print("✅ Visita creada exitosamente")
        } catch {
            print("❌ Error creando visita:", error)
            throw error
        }
    }
}

// Hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct VisitPlannerView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var showRouteSheet: Bool
    @Binding var estimatedTime: String
    var usuarioId: UUID
    var onRutaCalculada: (Visita) -> Void

    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var selectedDuration: String? = nil
    @State private var customHours: Int = 0
    @State private var customMinutes: Int = 0
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var isLoading = false // Para mostrar loading mientras se guarda
    @State private var showError = false // Para mostrar errores
    @State private var errorMessage = ""

    init(showRouteSheet: Binding<Bool>, estimatedTime: Binding<String>, usuarioId: UUID, onRutaCalculada: @escaping (Visita) -> Void) {
        self._showRouteSheet = showRouteSheet
        self._estimatedTime = estimatedTime
        self.usuarioId = usuarioId
        self.onRutaCalculada = onRutaCalculada
    }

    private var today: Date { Date() }
    private var maxDate: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: today)!
    }

    private var availableDates: [Date] {
        var dates: [Date] = []
        var current = today

        while current <= maxDate {
            if Calendar.current.component(.weekday, from: current) != 2 {
                dates.append(current)
            }
            current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
        }

        return dates
    }

    private var isMonday: Bool {
        Calendar.current.component(.weekday, from: selectedDate) == 2
    }
    
    // MARK: - Funciones para obtener horarios del museo
    private func getMuseumHours(for date: Date) -> (openHour: Int, closeHour: Int) {
        let weekday = Calendar.current.component(.weekday, from: date)
        
        if (3...5).contains(weekday) { // Martes a Jueves
            return (openHour: 11, closeHour: 18) // 11 AM - 6 PM
        } else if weekday == 6 || weekday == 7 || weekday == 1 { // Viernes, Sábado, Domingo
            return (openHour: 12, closeHour: 19) // 12 PM - 7 PM
        } else {
            return (openHour: 0, closeHour: 0) // Lunes cerrado
        }
    }
    
    private var selectedDurationInMinutes: Int {
        if selectedDuration == "Otro" {
            return customHours * 60 + customMinutes
        } else {
            switch selectedDuration {
            case "30 min": return 30
            case "1 hora": return 60
            case "2 horas": return 120
            case "3 horas": return 180
            case "4 horas": return 240
            case "5 horas": return 300
            default: return 0
            }
        }
    }

    private var validHourRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let museumHours = getMuseumHours(for: selectedDate)
        
        // Hora de apertura
        var startComponents = components
        startComponents.hour = museumHours.openHour
        startComponents.minute = 0
        
        // Hora límite considerando la duración de la visita
        let durationInMinutes = selectedDurationInMinutes
        let latestStartHour = museumHours.closeHour
        let latestStartMinutes = durationInMinutes
        
        // Calcular la hora más tarde que se puede empezar
        let totalCloseMinutes = latestStartHour * 60
        let latestStartInMinutes = totalCloseMinutes - latestStartMinutes
        
        let finalHour = max(museumHours.openHour, latestStartInMinutes / 60)
        let finalMinute = latestStartInMinutes % 60
        
        var endComponents = components
        endComponents.hour = finalHour
        endComponents.minute = finalMinute
        
        // Si la hora de cierre calculada es antes de la apertura, usar la apertura
        if finalHour < museumHours.openHour || (finalHour == museumHours.openHour && finalMinute < 0) {
            endComponents.hour = museumHours.openHour
            endComponents.minute = 0
        }
        
        let startDate = calendar.date(from: startComponents)!
        let endDate = calendar.date(from: endComponents)!
        
        // Asegurar que el rango sea válido
        if startDate >= endDate {
            // Si no hay tiempo suficiente, el rango será muy pequeño
            var limitedEnd = startComponents
            limitedEnd.minute = 30 // Al menos 30 minutos de diferencia
            return startDate...calendar.date(from: limitedEnd)!
        }
        
        return startDate...endDate
    }
    
    // MARK: - Validaciones
    private var hasEnoughTimeForVisit: Bool {
        let museumHours = getMuseumHours(for: selectedDate)
        let durationInMinutes = selectedDurationInMinutes
        let totalMuseumTime = (museumHours.closeHour - museumHours.openHour) * 60
        
        return durationInMinutes <= totalMuseumTime && durationInMinutes > 0
    }
    
    private var timeConflictMessage: String? {
        guard selectedDuration != nil && !hasEnoughTimeForVisit else { return nil }
        
        let museumHours = getMuseumHours(for: selectedDate)
        let totalHours = museumHours.closeHour - museumHours.openHour
        
        if selectedDurationInMinutes > totalHours * 60 {
            return "La duración seleccionada (\(formatDuration(selectedDurationInMinutes))) excede el horario del museo (\(totalHours) horas disponibles)."
        }
        
        return nil
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)min"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)min"
        }
    }

    private var customDurationValid: Bool {
        if selectedDuration == "Otro" {
            let totalMinutes = customHours * 60 + customMinutes
            return totalMinutes >= 15 && totalMinutes <= 390 // Entre 15 min y 6h 30min
        }
        return true
    }

    private var canContinue: Bool {
        !isMonday &&
        selectedDuration != nil &&
        customDurationValid &&
        hasEnoughTimeForVisit &&
        !isLoading
    }
    
    // MARK: - Función para crear y guardar la visita
    private func crearYGuardarVisita() async {
        isLoading = true
        
        do {
            // Calcular tiempo en minutos
            let tiempo = selectedDurationInMinutes
            
            // *** DEBUGGING: Imprimir valores antes de cualquier validación ***
            print("🔍 DEBUG - Valores iniciales:")
            print("   selectedDuration: \(selectedDuration ?? "nil")")
            print("   customHours: \(customHours)")
            print("   customMinutes: \(customMinutes)")
            print("   tiempo calculado: \(tiempo) minutos")
            
            // Validar que el tiempo sea válido ANTES de proceder
            guard tiempo > 0 else {
                throw NSError(domain: "VisitaError", code: 1006, userInfo: [NSLocalizedDescriptionKey: "El tiempo de visita debe ser mayor a 0 minutos. Valor actual: \(tiempo)"])
            }
            
            // Validar límites razonables
            guard tiempo >= 15 else {
                throw NSError(domain: "VisitaError", code: 1007, userInfo: [NSLocalizedDescriptionKey: "El tiempo mínimo de visita es 15 minutos. Valor seleccionado: \(tiempo)"])
            }
            
            // Límite máximo práctico (6.5 horas = 390 minutos)
            guard tiempo <= 390 else {
                throw NSError(domain: "VisitaError", code: 1008, userInfo: [NSLocalizedDescriptionKey: "El tiempo máximo de visita es 6 horas y 30 minutos. Valor seleccionado: \(formatDuration(tiempo))"])
            }
            
            // Formatear el tiempo estimado correctamente
            if selectedDuration == "Otro" {
                // Formatear según las horas y minutos
                if customHours > 0 && customMinutes > 0 {
                    estimatedTime = "\(customHours) hora\(customHours == 1 ? "" : "s") \(customMinutes) min"
                } else if customHours > 0 {
                    estimatedTime = "\(customHours) hora\(customHours == 1 ? "" : "s")"
                } else {
                    estimatedTime = "\(customMinutes) min"
                }
            } else {
                estimatedTime = selectedDuration ?? "30 min"
            }
            
            // Verificar que la fecha no sea en el pasado y no sea lunes
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let visitDate = calendar.startOfDay(for: selectedDate)
            
            // Permitir fechas de hoy en adelante
            guard visitDate >= today else {
                throw NSError(domain: "VisitaError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "La fecha de visita debe ser de hoy en adelante"])
            }
            
            let weekday = calendar.component(.weekday, from: selectedDate)
            guard weekday != 2 else { // 2 = lunes
                throw NSError(domain: "VisitaError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Los lunes el museo está cerrado"])
            }
            
            // Verificar que haya tiempo suficiente
            guard hasEnoughTimeForVisit else {
                throw NSError(domain: "VisitaError", code: 1004, userInfo: [NSLocalizedDescriptionKey: timeConflictMessage ?? "No hay tiempo suficiente para completar la visita"])
            }
            
            // Convertir el día de la semana a español según el constraint de la DB
            let diasSemana = [
                1: "domingo",    // Sunday
                2: "lunes",      // Monday
                3: "martes",     // Tuesday
                4: "miércoles",  // Wednesday
                5: "jueves",     // Thursday
                6: "viernes",    // Friday
                7: "sábado"      // Saturday
            ]
            
            guard let diaVisita = diasSemana[weekday] else {
                throw NSError(domain: "VisitaError", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Error al determinar el día de la semana"])
            }
            
            // Para la hora, usar solo los componentes de tiempo
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
            let horaInicio = String(format: "%02d:%02d:00", timeComponents.hour ?? 0, timeComponents.minute ?? 0)
            
            // Validar que la visita termine antes del cierre
            let startMinutes = (timeComponents.hour ?? 0) * 60 + (timeComponents.minute ?? 0)
            let endMinutes = startMinutes + tiempo
            let museumHours = getMuseumHours(for: selectedDate)
            let closeMinutes = museumHours.closeHour * 60
            
            guard endMinutes <= closeMinutes else {
                throw NSError(domain: "VisitaError", code: 1005, userInfo: [NSLocalizedDescriptionKey: "La visita terminaría después del horario de cierre del museo"])
            }
            
            // Debug: Imprimir valores antes de enviar
            print("📅 Fecha original: \(selectedDate)")
            print("📅 Día de la semana (número): \(weekday)")
            print("📅 Día de la semana (español): \(diaVisita)")
            print("🕐 Hora original: \(selectedTime)")
            print("🕐 Componentes de tiempo: hora=\(timeComponents.hour ?? 0), minuto=\(timeComponents.minute ?? 0)")
            print("🕐 Hora inicio formateada: \(horaInicio)")
            print("⏱️ Tiempo disponible: \(tiempo) minutos")
            print("🏛️ Horario museo: \(museumHours.openHour):00 - \(museumHours.closeHour):00")
            print("✅ Hora fin visita: \(endMinutes / 60):\(String(format: "%02d", endMinutes % 60))")
            
            // Crear objeto para la base de datos
            let visitaDB = VisitaDB(
                id: UUID(),
                usuario_id: usuarioId,
                dia_visita: diaVisita,
                hora_inicio_visita: horaInicio,
                tiempo_disponible: tiempo
            )
            
            print("🚀 Enviando a DB: \(visitaDB)")
            
            // Guardar en base de datos
            try await VisitaService.shared.crearVisita(visitaDB)
            
            // Crear objeto para la lógica de ruta (manteniendo compatibilidad)
            let visita = Visita(
                id: visitaDB.id,
                usuario_id: usuarioId,
                tiempo_disponible: tiempo
            )
            
            // Continuar con el flujo existente
            await MainActor.run {
                onRutaCalculada(visita)
                showRouteSheet = true
                isLoading = false
                dismiss()
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Error al guardar la visita: \(error.localizedDescription)"
                showError = true
                print("❌ Error completo: \(error)")
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header with gradient background
                headerSection
                
                // Date Selection
                dateSelectionSection
                
                // Duration Selection (movido antes de time para que la validación funcione)
                durationSelectionSection
                
                // Time Selection
                timeSelectionSection
                
                // Continue Button
                continueButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: selectedDuration) { _, _ in
            // Ajustar la hora si ya no es válida con la nueva duración
            let currentRange = validHourRange
            if selectedTime < currentRange.lowerBound {
                selectedTime = currentRange.lowerBound
            } else if selectedTime > currentRange.upperBound {
                selectedTime = currentRange.upperBound
            }
        }
        .onChange(of: customHours) { _, _ in
            // Ajustar la hora cuando cambie la duración personalizada
            if selectedDuration == "Otro" {
                let currentRange = validHourRange
                if selectedTime < currentRange.lowerBound {
                    selectedTime = currentRange.lowerBound
                } else if selectedTime > currentRange.upperBound {
                    selectedTime = currentRange.upperBound
                }
            }
        }
        .onChange(of: customMinutes) { _, _ in
            // Ajustar la hora cuando cambie la duración personalizada
            if selectedDuration == "Otro" {
                let currentRange = validHourRange
                if selectedTime < currentRange.lowerBound {
                    selectedTime = currentRange.lowerBound
                } else if selectedTime > currentRange.upperBound {
                    selectedTime = currentRange.upperBound
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("¡Planea tu visita!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "F7996E"), Color(hex: "F7996E").opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Organiza tu experiencia perfecta")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        dismiss()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .background(Circle().fill(.ultraThinMaterial))
                }
            }
            
            Divider()
                .background(LinearGradient(
                    colors: [.clear, Color(hex: "F7996E").opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
        }
    }
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "¿Qué día nos visitas?",
                icon: "calendar",
                color: .blue
            )
            
            Button(action: {
                withAnimation(.spring(response: 0.4)) {
                    showingDatePicker.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Mostrar horarios del museo
                    if !isMonday {
                        let hours = getMuseumHours(for: selectedDate)
                        Text("\(hours.openHour):00 - \(hours.closeHour):00")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    
                    Image(systemName: showingDatePicker ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(showingDatePicker ? 180 : 0))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .stroke(LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
            }
            
            if showingDatePicker {
                DatePicker("Fecha", selection: $selectedDate, in: today...maxDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
            
            if isMonday {
                alertMessage(
                    text: "Los lunes el museo está cerrado.",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
            }
        }
    }
    
    private var timeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "¿A qué hora planeas llegar?",
                icon: "clock",
                color: .green
            )
            
            if selectedDuration == nil {
                alertMessage(
                    text: "Primero selecciona la duración de tu visita para ver los horarios disponibles.",
                    icon: "info.circle.fill",
                    color: .blue
                )
            } else {
                Button(action: {
                    withAnimation(.spring(response: 0.4)) {
                        showingTimePicker.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Text(selectedTime.formatted(date: .omitted, time: .shortened))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Mostrar hora estimada de finalización
                        if selectedDurationInMinutes > 0 {
                            let endTime = Calendar.current.date(byAdding: .minute, value: selectedDurationInMinutes, to: selectedTime)!
                            Text("Fin: \(endTime.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                        
                        Image(systemName: showingTimePicker ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(showingTimePicker ? 180 : 0))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .stroke(LinearGradient(
                                colors: [.green.opacity(0.3), .green.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1)
                    )
                }
                
                if showingTimePicker {
                    DatePicker(
                        "Hora",
                        selection: $selectedTime,
                        in: validHourRange,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                
                // Mostrar mensaje de conflicto si existe
                if let conflictMessage = timeConflictMessage {
                    alertMessage(
                        text: conflictMessage,
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    )
                }
            }
        }
    }
    
    private var durationSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "¿Cuánto tiempo estarás en el museo?",
                icon: "hourglass",
                color: .purple
            )
            
            let durationOptions = ["30 min", "1 hora", "2 horas", "3 horas", "4 horas", "5 horas", "Otro"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(durationOptions, id: \.self) { option in
                    durationButton(option: option)
                }
            }
            
            if selectedDuration == "Otro" {
                customDurationPicker
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                
                // Mostrar validación de duración personalizada
                if !customDurationValid {
                    let currentDuration = selectedDurationInMinutes
                    if currentDuration < 15 {
                        alertMessage(
                            text: "Selecciona al menos 15 minutos de duración.",
                            icon: "exclamationmark.triangle.fill",
                            color: .orange
                        )
                    } else if currentDuration > 390 {
                        alertMessage(
                            text: "El tiempo máximo es 6 horas y 30 minutos. Tiempo actual: \(formatDuration(currentDuration)).",
                            icon: "exclamationmark.triangle.fill",
                            color: .orange
                        )
                    }
                }
            }
        }
    }
    
    private func durationButton(option: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedDuration = option
                
                // Si selecciona "Otro" y no hay valores válidos, establecer por defecto
                if option == "Otro" && customHours == 0 && customMinutes == 0 {
                    customMinutes = 30 // Valor por defecto de 30 minutos
                }
            }
        }) {
            Text(option)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(selectedDuration == option ? Color(hex: "F7996E") : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedDuration == option ? Color(hex: "F7996E").opacity(0.2) : .clear)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedDuration == option ? Color(hex: "F7996E") : .secondary.opacity(0.2), lineWidth: selectedDuration == option ? 2 : 1)
                )
                .scaleEffect(selectedDuration == option ? 1.05 : 1.0)
        }
    }
    
    private var customDurationPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Selecciona la duración personalizada")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Horas")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Picker("Horas", selection: $customHours) {
                        ForEach(0..<7) { hour in // Hasta 6 horas (para permitir 6h 30min)
                            Text("\(hour)")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                VStack(spacing: 8) {
                    Text("Minutos")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Picker("Minutos", selection: $customMinutes) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text("\(minute)")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .onAppear {
                        // Si no hay horas seleccionadas, asegurar que haya al menos 15 minutos
                        if customHours == 0 && customMinutes == 0 {
                            customMinutes = 30
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            Task {
                await crearYGuardarVisita()
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }

                Text(isLoading ? "Guardando..." : "Continuar")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(canContinue ?
                          LinearGradient(colors: [Color(hex: "F7996E"), Color(hex: "F7996E").opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .shadow(color: canContinue ? Color(hex: "F7996E").opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
            .scaleEffect(canContinue ? 1.0 : 0.95)
        }
        .disabled(!canContinue)
    }

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 24)

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()
        }
    }
    
    private func alertMessage(text: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.callout)
            
            Text(text)
                .font(.callout)
                .foregroundColor(color)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
