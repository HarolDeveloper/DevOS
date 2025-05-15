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
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0


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
            Color(hex: "FE915E").ignoresSafeArea()

            
            GeometryReader { geo in
                        ZStack {
                            ZStack {
                                Image("map_placeholder")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width, height: geo.size.height)

                                if let selected = selectedExperienceID,
                                   let selectedExperience = ExperienceData.all.first(where: { $0.id == selected }) {

                                    let start = CGPoint(x: 0.25, y: 0.06)
                                    let end = selectedExperience.position

                                    Path { path in
                                        path.move(to: CGPoint(x: start.x * geo.size.width, y: start.y * geo.size.height))
                                        path.addLine(to: CGPoint(x: end.x * geo.size.width, y: end.y * geo.size.height))
                                    }
                                    .stroke(Color.purple, lineWidth: 5)
                                    .animation(.easeInOut, value: selectedExperienceID)


                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 16, height: 16)
                                        .position(x: end.x * geo.size.width, y: end.y * geo.size.height)
                                }
                            }
                            .scaleEffect(scale * gestureScale)
                            .offset(x: offset.width + gestureOffset.width, y: offset.height + gestureOffset.height)
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .updating($gestureScale) { currentState, gestureState, _ in
                                            gestureState = currentState
                                        }
                                        .onEnded { value in
                                            scale *= value
                                        },
                                    DragGesture()
                                        .updating($gestureOffset) { value, state, _ in
                                            state = value.translation
                                        }
                                        .onEnded { value in
                                            offset.width += value.translation.width
                                            offset.height += value.translation.height
                                        }
                                )
                            )
                        }
                    }

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

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // optional #
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
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
