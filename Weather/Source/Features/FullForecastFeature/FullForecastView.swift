//
//  FullForecastView.swift
//  Weather
//
//  Created by jonathan saville on 15/06/2024.
//

import SwiftUI
import CoreLocation
import ComposableArchitecture
import WeatherNetworkingKit

struct FullForecastView: View {
    @Bindable var store: StoreOf<FullForecast>

    private let viewHelper: FullForecastViewHelper

    init(store: StoreOf<FullForecast>) {
        self.store = store
        viewHelper = FullForecastViewHelper(forecast: store.state.forecast)
    }
    
    var body: some View {
        
        NavigationStack() {
            ZStack {
                Color.navbarBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Divider()
                        .background(Color.backgroundPrimary)
                    
                    Text(store.state.forecast.displayLocationName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.largeFontBold)
                        .padding([.bottom, .leading, .trailing])
                        .background(Color.backgroundPrimary)
                        .transaction { transaction in transaction.animation = nil }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(Array(store.state.forecast.daily.enumerated()), id: \.offset) { index, dailyForecast in
                                DayForecastView(dailyForecast: dailyForecast, timezoneOffset: store.state.forecast.timezoneOffset)
                                    .frame(width: UIScreen.main.bounds.width / 4.6)
                                    .background(index == store.state.selectedDay ? Color.navbarBackground : Color.backgroundPrimary)
                                    .overlay(index == store.state.selectedDay ? RoundedRectangle(cornerRadius: 8).stroke(.white, lineWidth: 1) : nil)
                                    .onTapGesture() { store.send(.dayTapped(index)) }
                            }
                        }
                        .frame(height: DayForecastView.preferredHeight)
                        .padding(.bottom, 8)
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $store.dailyScrollIndex.sending(\.dailyScrollIndex), anchor: .center)
                    .animation(.linear, value: store.state.isAnimationEnabled ? store.state.dailyScrollIndex : nil)
                    .background(Color.backgroundPrimary)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {

                            DaySummaryView(forecast: store.state.forecast, selectedDay: store.state.selectedDay)
                                .padding([.top, .bottom])
                                .transaction { transaction in transaction.animation = nil }

                            SlidingSelectorView(store: store.scope(state: \.slidingSelectorState, action: \.slidingSelectorState))
                                .padding(16)
                                .background(Color.backgroundPrimary)
                                .clipShape(.rect(topLeadingRadius: RoundedCorners.defaultRadius, topTrailingRadius: RoundedCorners.defaultRadius))
                                .padding([.leading, .trailing], 8)
 
                            ZStack() {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    VStack(spacing: 0) {
                                        HourlyForecastsView(forecast: store.state.forecast, contentType: .multiple(store.state.selectorState), viewHelper: viewHelper)
                                    
                                        Rectangle() // make room for the non-scrolling overlay
                                            .frame(height: FullForecastOverlayView.height)
                                    
                                        HourlyForecastsView(forecast: store.state.forecast, contentType: .wind, viewHelper: viewHelper)
                                    }
                                }
                                .scrollTargetLayout()
                                .scrollPosition(id: $store.hourlyScrollIndex.sending(\.hourlyScrollIndex)) // THIS MAKES THE SCROLLING JITTERY!!!!!
                                .animation(.linear, value: store.state.isAnimationEnabled ? store.state.hourlyScrollIndex : nil)

                                FullForecastOverlayView(store: store.scope(state: \.fullForecastOverlayState, action: \.fullForecastOverlayState))
                                    .frame(height: FullForecastOverlayView.height)
                                    .background(Color.navbarBackground)
                                    .offset(y: ((HourForecastMultipleView.preferredHeight - HourForecastWindView.preferredHeight) / 2))
                            }
                            .background(Color.backgroundPrimary)
                            .padding([.leading, .trailing], 8)

                            ScrollButtonsView(store: store.scope(state: \.scrollButtonsState, action: \.scrollButtonsState))
                                .padding([.top, .bottom], 8)
                                .background(Color.backgroundPrimary)
                                .clipShape(.rect( bottomLeadingRadius: RoundedCorners.defaultRadius,
                                                  bottomTrailingRadius: RoundedCorners.defaultRadius))
                                .padding([.leading, .trailing], 8)

                            SunriseSunsetView(forecast: store.state.forecast, selectedDay: store.state.dailyScrollIndex ?? 0)
                                .padding(16)
                                .background(Color.backgroundPrimary)
                                .cornerRadius(RoundedCorners.defaultRadius)
                                .padding([.leading, .trailing], 8)
                                .padding([.top], 24)
                        }
                    }
                }
                .foregroundColor(.defaultText)
                .font(.defaultFont)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar {
                    Group {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close", role: .cancel) { store.send(.closeButtonTapped) }
                                .buttonStyle(PrimaryButtonStyle())
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            ShareLink(item: "\(store.state.forecast.summaryDescription(for: store.state.dailyScrollIndex ?? 0))") {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                }
                .onAppear() {
                    store.send(.onAppear)
                }
            }
        }
    }
}

extension Forecast {
    func summaryDescription(for day: Int) -> String {
        guard let dailyForecast = daily[safe: day],
              let date = dailyForecast.date.dayOfWeek(timezoneOffset, dayFormat: "EEEE"),
              let location = location?.fullName else { return "No data" }
        
        return "Weather forecast for \(location) from the Weather App. \(date): \(dailyForecast.summary.lowercaseFirstChar)"
    }
}

#Preview {
    let location = Location(coordinates: CLLocationCoordinate2D(latitude: 41.8933203, longitude: 12.4829321), name: "Rome (Lazio)")
    let forecast: Forecast = try! MockAPIService().getForecast(for: location.coordinates, from: [location])
    
    return FullForecastView(
        store: Store(initialState: FullForecast.State(forecast, selectedDay: 0)) { FullForecast() }
    )
}
