//
///  NavBarView.swift
//  DevOS
//
//  Created by Bernardo Caballero on 29/04/25.
//

import SwiftUI

struct NavBarView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        VStack(spacing: 0) {
            // Swipeable views - SIN NavigationStack aquí
            TabView(selection: $selectedTab) {
                CameraView().tag(Tab.camera)
                HomeView().tag(Tab.home)  // Sin NavigationStack
                MapView().tag(Tab.map)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom NavBar
            HStack {
                Spacer()
                Button {
                    selectedTab = .camera
                } label: {
                    Image("logoCamera")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(selectedTab == .camera ? .white : .gray)
                }

                Spacer()
                Button {
                    selectedTab = .home
                } label: {
                    ZStack {
                        Circle()
                            .fill(selectedTab == .home ? Color.black : Color.clear)
                            .frame(width: 44, height: 44)

                        Image("logoHome")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(selectedTab == .home ? .white : .gray)
                    }
                }

                Spacer()
                Button {
                    selectedTab = .map
                } label: {
                    Image("logoMap")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(selectedTab == .map ? .white : .gray)
                }
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(Color.black)
            .cornerRadius(20)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
    }
}
