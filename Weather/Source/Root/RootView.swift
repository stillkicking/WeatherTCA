//
//  RootView.swift
//  Weather
//
//  Created by jonathan saville on 28/05/2024.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    var store: StoreOf<Root>

    var body: some View {

        TabView {
            Group {
                WeatherView(
                    store: Store(
                        initialState: Weather.State()
                    ) {
                        Weather()
                    }
                )
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                        .environment(\.symbolVariants, .none)
                }

                MapsView(
                    store: Store(
                        initialState: Maps.State()
                    ) {
                        Maps()
                    }
                )
                .tabItem {
                    Label("Maps", systemImage: "map")
                        .environment(\.symbolVariants, .none)
                }
                    
                WarningsView(
                    store: Store(
                        initialState: Warnings.State()
                    ) {
                        Warnings()
                    }
                )
                .tabItem {
                    Label("Warnings", systemImage: "exclamationmark.triangle")
                        .environment(\.symbolVariants, .none)
                }
            }
            .toolbarBackground(Color.backgroundSecondary.opacity(0.7), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
}

#Preview {
    RootView(
        store: Store(initialState: Root.State()) {
            Root()
        }
    )
}
