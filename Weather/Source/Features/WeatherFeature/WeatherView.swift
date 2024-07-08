//
//  WeatherView.swift
//  Weather
//
//  Created by jonathan saville on 28/05/2024.
//

import SwiftUI
import ComposableArchitecture
import WeatherNetworkingKit

struct WeatherView: View {
    
    @Bindable var store: StoreOf<Weather>

    var body: some View {
        NavigationStack {
            ZStack {
                    
                LinearGradient(gradient: Gradient(colors: [.backgroundGradientFrom,
                                                           .backgroundGradientTo]), startPoint: .bottom, endPoint: .top)
                Group {
                    switch store.state.loading {
                    case .idle:
                        EmptyView() // TBD - put a splash screen here?
                    case .loading:
                        ActivityIndicator()
                            .frame(width: 44, height: 44)
                            .background(.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    case .loaded:
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 16) {
                                if store.state.forecasts.isEmpty {
                                    if store.state.showVideo {
                                        VideoForecastView()
                                            .displayAsCard()
                                    } else {
                                        Text(CommonStrings.noForecastItems) // TBD - make more user-friendly?
                                            .foregroundColor(.defaultText)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 300)
                                            .padding(.top, 100)
                                    }
                                } else {
                                    ForEach( Array(store.scope(state: \.forecasts, action: \.forecasts).enumerated()), id: \.element) { index, childStore in
                                        SummaryForecastView(store: childStore)
                                        
                                        if store.state.showVideo && index == 0 { // video is the second item or the first if the only item
                                            VideoForecastView()
                                        }
                                    }
                                    .displayAsCard()
                                }
                            }
                            .padding(.bottom, 16)
                        }
                        .padding(0)
                        .padding(.top, 8)
                        .refreshable { store.send(.reloadForecastsRequested) }
                    
                    case .error(let apiError):
                        Text(String(describing: apiError)) // TBD - make more user-friendly
                            .foregroundColor(.defaultText)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.navbarBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { store.send(.settingsButtonTapped) } label: { Image(systemName: "gearshape") }
                    }

                    ToolbarItem(placement: .principal) {
                        NavBarTitleView.weather
                    }
                        
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { store.send(.editButtonTapped) } label: { Text("Edit") }
                    }
                }
                
                .sheet(item: $store.scope(state: \.settingsState, action: \.settingsState)) { store in
                    SettingsView(store: store)
                }
                
                .fullScreenCover(item: $store.scope(state: \.locationsState, action: \.locationsState)) { store in
                    LocationsView(store: store)
                }
                .transaction { transaction in transaction.disablesAnimations = true }
                
                .fullScreenCover(item: $store.scope(state: \.fullForecastState, action: \.fullForecastState)) { store in
                    FullForecastView(store: store)
                }
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}

#Preview {
    WeatherView(
        store: Store(initialState: Weather.State()) { Weather() }
    )
}
