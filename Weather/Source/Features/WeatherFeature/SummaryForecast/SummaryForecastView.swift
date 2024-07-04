//
//  SummaryForecastView.swift
//  Weather
//
//  Created by jonathan saville on 05/06/2024.
//

import CoreLocation
import SwiftUI
import ComposableArchitecture
import WeatherNetworkingKit

struct SummaryForecastView: View {
    
    @Bindable var store: StoreOf<SummaryForecast>
    
    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text(store.state.forecast.displayLocationName)
                .font(.largeFontBold)
                .padding(.top, 16)
                .padding(.leading, 12)
 
            ScrollView(.horizontal, showsIndicators: false) {

                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(store.state.forecast.daily.enumerated()), id: \.offset) { index, dailyForecast in
                        VStack(spacing: 8) {
                            // day
                            Text(dailyForecast.date.dayOfWeek(store.state.forecast.timezoneOffset) ?? "-")
                                .font(.largeFont)
                                .padding(.bottom, 8)
                                
                            WeatherIcon(fromOpenWeatherCode: dailyForecast.displayable.first?.icon ?? "")
                                .frame(height: 40)
                                .padding(.bottom, 0)
                                
                            // max temperature
                            Text(dailyForecast.temperature.max.temperatureString)
                                .font(.largeFont)
                                .padding(.bottom, 4)
                                
                            // min temperature
                            Text(dailyForecast.temperature.min.temperatureString)
                                .font(.defaultFont)
                                .padding(.bottom, 4)
                        }
                        .foregroundColor(.defaultText)
                        .frame(width: (UIScreen.main.bounds.width - 16) / CGFloat(SummaryForecastViewHelper.numElementsPerScreen))
                        .background(Color.backgroundPrimary)
                        .onTapGesture { store.send(.dayTapped(index)) }
                    }
                }
            }
            .scrollTargetLayout()
            .scrollPosition(id: $store.scrollIndex.sending(\.scrollIndex))
            .animation(.linear, value: store.state.scrollIndex) // ensures animation occurs when the scroll left/right buttons are tapped
            HStack {
                Button { store.send(.fullForecastTapped) } label: { Text("View full forecast") }
                    .font(.defaultFont)
                    .padding(.bottom, 16)
                    .padding(.leading, 12)
                    .buttonStyle(PrimaryButtonStyle())

                Spacer()

                ScrollButtonsView(store: store.scope(state: \.scrollButtonsState, action: \.scrollButtonsState))
                    .frame(height: 24)
                    .offset(y: -8)
            }
            .background(Color.backgroundPrimary)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let location = Location(coordinates: CLLocationCoordinate2D(latitude: 41.8933203, longitude: 12.4829321), name: "Rome (Lazio)")
    let forecast: Forecast = try! MockAPIService().getForecast(for: location.coordinates, from: [location])

    return SummaryForecastView(
        store: Store(initialState: SummaryForecast.State(forecast: forecast)) {
            SummaryForecast()
        }
    )
}
