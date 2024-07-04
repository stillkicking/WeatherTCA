//
//  HourlyForecastsView.swift
//  Weather
//
//  Created by jonathan saville on 09/11/2023.
//

import SwiftUI
import CoreLocation
import WeatherNetworkingKit

struct HourlyForecastsView: View {
    
    enum ContentType {
        case wind
        case multiple(SelectorState)
    }
    
    let forecast: Forecast
    let contentType: ContentType
    let viewHelper: FullForecastViewHelper
    
    private let containerWidth = UIScreen.main.bounds.width
    private let horizontalPadding: CGFloat = 16
    private let trailingPadding: CGFloat = 28
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            let timezoneOffset = forecast.timezoneOffset
            let width = (containerWidth - horizontalPadding) / CGFloat(viewHelper.numElementsPerScreen)
            var height: CGFloat {switch contentType { case .multiple: return HourForecastMultipleView.preferredHeight; case .wind: return HourForecastWindView.preferredHeight }}
            
            ForEach(Array(forecast.hourly.enumerated()), id: \.offset) { index, hourlyForecast in
                let isLastForecast = forecast.hourly.last?.id == hourlyForecast.id
                
                HStack(spacing: 0) {
                    
                    if viewHelper.shouldDisplaySeparator(for: index) {
                        HourForecastSeparatorView(day: hourlyForecast.date.dayOfWeek(timezoneOffset) ?? "-")
                            .frame(width: width, height: height)
                    }
                    
                    switch contentType {
                    case .multiple(let state):
                        HourForecastMultipleView(hourlyForecast: hourlyForecast,
                                                 timezoneOffset: timezoneOffset,
                                                 selectorState: state)
                        .frame(width: width, height: height)
                        .padding(.trailing, isLastForecast ? trailingPadding : 0)
                        
                    case .wind:
                        HourForecastWindView(hourlyForecast: hourlyForecast,
                                             timezoneOffset: timezoneOffset)
                        .frame(width: width, height: height)
                        .padding(.trailing, isLastForecast ? trailingPadding : 0)
                    }
                }
            }
        }
    }
}

struct HourlyForecastsView_Previews: PreviewProvider {
    static let location = Location(coordinates: CLLocationCoordinate2D(latitude: 41.8933203, longitude: 12.4829321), name: "Rome (Lazio)")
    static var forecast: Forecast = try! MockAPIService().getForecast(for: location.coordinates, from: [location])
    
    static var previews: some View {
        let viewHelper = FullForecastViewHelper(forecast: forecast)

        HourlyForecastsView(forecast: forecast, contentType: .multiple(.precipitation), viewHelper: viewHelper)
            .background(.gray)
            .preferredColorScheme(.dark)
   }
}
