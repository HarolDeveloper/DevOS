//
//  RouteSheetView.swift
//  DevOS
//
//  Created by Fernando Rocha on 05/06/25.
//

import SwiftUI

struct RouteCardView: View {
    var number: String
    var title: String
    var emoji: String
    var imageURL: String?
    var isSelected: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                if let urlString = imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 180, height: 110)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 110)
                                .clipped()
                                .cornerRadius(14)
                        case .failure:
                            ZStack {
                                Color.gray.opacity(0.1)
                                Text(emoji)
                                    .font(.system(size: 40))
                            }
                            .frame(width: 180, height: 110)
                            .cornerRadius(14)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    ZStack {
                        Color.gray.opacity(0.1)
                        Text(emoji)
                            .font(.system(size: 40))
                    }
                    .frame(width: 180, height: 110)
                    .cornerRadius(14)
                }

                Text(number)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
            }
            .frame(width: 180)
            .padding(8)
            .background(isSelected ? Color(red: 0.992, green: 0.812, blue: 0.729) : Color.clear)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RouteSheetView: View {
    var route: Route
    @Binding var isPresented: Bool
    @Binding var selectedExperienceID: UUID? // Agregar binding para la selección
    var onDismiss: () -> Void

    @State private var isCollapsed: Bool = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.55)

    var body: some View {
        VStack(spacing: 16) {
            if !isCollapsed {
                expandedContent
            } else {
                collapsedContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .padding(.top)
        .safeAreaInset(edge: .bottom) {
            // Espacio para el navbar
            Color.clear.frame(height: 20)
        }
        .presentationDetents(
            [.fraction(0.15), .fraction(0.55)],
            selection: $selectedDetent
        )
        .interactiveDismissDisabled()
        .onChange(of: selectedDetent) { newValue in
            withAnimation {
                isCollapsed = newValue == .fraction(0.15)
            }
        }
        .onAppear {
            isCollapsed = false
            selectedDetent = .fraction(0.55)
        }
    }
    
    @ViewBuilder
    private var expandedContent: some View {
        VStack(spacing: 16) {
            Text("¡Sigue esta ruta!")
                .font(.title2)
                .bold()
                .padding(.top, 4)

            routeCardsScrollView
            
            bottomActionBar
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var collapsedContent: some View {
        HStack(spacing: 16) {
            Text("Tiempo estimado")
                .font(.title3)
                .foregroundColor(.gray)
                .padding()
            Circle()
                .frame(width: 6, height: 6)
            Text(route.estimatedTime)
                .font(.title3)
                .foregroundColor(.gray)
                .padding()
                .bold()
        }
        .font(.subheadline)
        .foregroundColor(.gray)
        .padding()
    }
    
    @ViewBuilder
    private var routeCardsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            routeCardsHStack
        }
    }
    
    @ViewBuilder
    private var routeCardsHStack: some View {
        HStack(spacing: 20) {
            ForEach(Array(route.experienceIDs.enumerated()), id: \.offset) { index, experienceID in
                routeCard(for: experienceID, at: index)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func routeCard(for experienceID: UUID, at index: Int) -> some View {
        if let experience = ExperienceData.all.first(where: { $0.id == experienceID }) {
            RouteCardView(
                number: "#\(index + 1)",
                title: experience.title,
                emoji: experience.emoji,
                imageURL: nil,
                isSelected: selectedExperienceID == experienceID,
                onTap: {
                    selectedExperienceID = experienceID
                }
            )
        }
    }
    
    @ViewBuilder
    private var bottomActionBar: some View {
        HStack {
            Button(action: {
                isPresented = false
                onDismiss()
            }) {
                Text("Salir")
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(Color.red)
                    .cornerRadius(14)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("Tiempo estimado")
                    .font(.title3)
                Circle()
                    .frame(width: 6, height: 6)
                Text(route.estimatedTime)
                    .bold()
                    .font(.title3)
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.bottom, 20) // Reducir el padding
    }
}
