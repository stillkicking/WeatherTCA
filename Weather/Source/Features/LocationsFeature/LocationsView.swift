//
//  LocationsView.swift
//  Weather
//
//  Created by jonathan saville on 19/06/2024.
//

import SwiftUI
import ComposableArchitecture
import WeatherNetworkingKit

struct LocationsView: View {
    
    @Bindable var store: StoreOf<Locations>
    
    private let backgroundColor = Color.navbarBackground

    var body: some View {
        NavigationStack() {
            ZStack {
                backgroundColor.ignoresSafeArea()

                List() {
                    Group {
                        HStack() {
                            Image(systemName: "magnifyingglass")
                                .font(.defaultFont)
                                
                            Text("Search & save your places")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.defaultText.opacity(0.6))
                        }
                        .background(Color.backgroundPrimary) // ensures onTapGesture is triggered for the whole HStack
                        .onTapGesture { store.send(.searchTapped) }

                        Toggle(Flag.showCurrentLocation.description,
                                isOn: $store.showCurrentLocation.sending(\.toggleShowCurrentLocation))

                        Toggle(Flag.showVideo.description,
                                isOn: $store.showVideo.sending(\.toggleShowVideo))

                        ForEach(Array(store.state.locations.enumerated()), id: \.offset) { index, location in
                            HStack(spacing: 12) {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.defaultText.opacity(0.6))
                                    .padding(.leading, 4)
                                Text(location.name)
                                Spacer()
                                Image(systemName: "minus.circle.fill")
                                    .padding(.trailing, 12)
                                    .symbolRenderingMode(.multicolor)
                                    .onTapGesture { store.send(.deleteLocation(at: index)) }
                            }
                        }
                        .onMove { from, to in
                            guard let from = from.first else { return }
                            store.send(.moveLocation(from: from, to: to))
                        }
                    }
                    .tint(.accentColor)
                    .font(.largeFont)
                    .foregroundColor(.defaultText)
                    .padding([.leading, .trailing], 12)
                    .frame(height: 50)
                    .listRowBackground(Color.backgroundGradientTo)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top:0, leading: 0, bottom: 16, trailing: 0))
                    .displayAsCard()
                }
                .listStyle(.plain)
                .contentMargins(0, for: .scrollContent)
                .scrollContentBackground(.hidden)
                .padding(.top, 8)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbarBackground(backgroundColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        NavBarTitleView.weather
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { store.send(.doneButtonTapped) }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .alert( store: self.store.scope(state: \.$alert, action: \.alert))
                .onAppear() {
                    store.send(.onAppear)
                }
            }
        }
    }
}

#Preview {
    LocationsView(
        store: Store(initialState: Locations.State()) { Locations() }
    )
}

extension Flag {
    var description: String {
        switch self {
        case .showVideo: return "UK video forecast"
        case .showCurrentLocation: return CommonStrings.currentLocation
        }
    }
}
