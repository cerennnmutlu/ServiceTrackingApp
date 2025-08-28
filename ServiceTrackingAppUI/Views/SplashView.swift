//
//  SplashView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        Group {
            if isActive {
                if appState.isAuthenticated {
                    ContentView()
                } else {
                    LoginView()
                }
            } else {
                VStack {
                    Image("BusIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)) {
                                size = 0.9
                                opacity = 1.0
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation { isActive = true }
                    }
                }
            }
        }
    }
}

#Preview { SplashView().environmentObject(AppState()) }
