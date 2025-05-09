//
//  MapView.swift
//  DevOS
//
//  Created by Fernando Rocha on 29/04/25.
//

import SwiftUI

struct MapView: View {
    @State private var selectedExperienceID: UUID? = nil
    @State private var searchText = ""
    @State private var displayType: BottomSheetDisplayType = .none

    var filteredExperiences: [Experience] {
        if searchText.isEmpty {
            return ExperienceData.all
        } else {
            return ExperienceData.all.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            BottomSheetAdvanceView(displayType: $displayType, maxHeight: 640) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 23))

                        TextField("¿Qué quieres visitar?", text: $searchText)
                            .font(.system(size: 23))
                            .foregroundColor(.primary)
                            .frame(height: 44)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray5))
                    .cornerRadius(25)
                    Text("Opciones")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.top, 18)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(filteredExperiences.enumerated()), id: \.element.id) { index, experience in
                            Button(action: {
                                selectedExperienceID = experience.id
                            }) {
                                HStack(alignment: .top) {
                                    Text(experience.emoji)
                                        .font(.system(size: 22))

                                    Text(experience.title)
                                        .font(.system(size: 22, weight: .bold))
                                        .fixedSize(horizontal: false, vertical: true)

                                    Spacer()

                                    if index == 0 {
                                        Text("Recomendado")
                                            .font(.system(size: 18))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 11)
                                            .background(Color.blue.opacity(0.7))
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(selectedExperienceID == experience.id ? Color(.systemGray5) : Color.clear)
                                .cornerRadius(12)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0.3
}

public enum BottomSheetDisplayType {
    case fullScreen
    case halfScreen
    case none
}

struct BottomSheetAdvanceView<Content: View>: View {
    @Binding var displayType: BottomSheetDisplayType

    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content

    @GestureState private var translation: CGFloat = 0
    private var offset: CGFloat {
        switch displayType {
        case .fullScreen:
            return 0
        case .halfScreen:
            return maxHeight * 0.40
        case .none:
            return maxHeight - minHeight
        }
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(width: Constants.indicatorWidth, height: Constants.indicatorHeight)
    }

    init(displayType: Binding<BottomSheetDisplayType>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = 140
        self.maxHeight = maxHeight
        self.content = content()
        self._displayType = displayType
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator.padding()
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(Constants.radius)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring(), value: displayType)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistanceFullScreen = self.maxHeight * 0.35
                    let snapDistanceHalfScreen = self.maxHeight * 0.85
                    if value.location.y <= snapDistanceFullScreen {
                        self.displayType = .fullScreen
                    } else if value.location.y > snapDistanceFullScreen && value.location.y <= snapDistanceHalfScreen {
                        self.displayType = .halfScreen
                    } else {
                        self.displayType = .none
                    }
                }
            )
        }
    }
}

#Preview {
    MapView()
}
