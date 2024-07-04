//
//  DayForecastView.swift
//  Weather
//
//  Created by jonathan saville on 09/10/2023.
//

import SwiftUI
import CoreLocation
import WeatherNetworkingKit

struct DayForecastView: View {
    let dailyForecast: DailyForecast
    let timezoneOffset: Int

    static let preferredHeight = Constants.imageHeight + // icon
                                 Constants.fontLineHeight + // day of week
                                 Constants.bottomPadding

    private static let verticalSpacing: CGFloat = 8
    
    private enum Constants {
        static let imageHeight: CGFloat = 40
        static let font = Font.largeFont
        static let fontLineHeight = Font.largeFontLineHeight
        static let bottomPadding: CGFloat = 8
    }

    var body: some View {
        VStack(spacing: 0) {
            WeatherIcon(fromOpenWeatherCode: dailyForecast.displayable.first?.icon ?? "")
                .frame(height: Constants.imageHeight)
                .padding(.bottom, 0)

            Text(dailyForecast.date.dayOfWeek(timezoneOffset) ?? "-")
                .font(Constants.font)
                .padding(.bottom, Constants.bottomPadding)
       }
    }
}

struct DayForecastView_Previews: PreviewProvider {
    static let location = Location(coordinates: CLLocationCoordinate2D(latitude: 41.8933203, longitude: 12.4829321), name: "Rome (Lazio)")
    static let forecast: Forecast = try! MockAPIService().getForecast(for: location.coordinates, from: [location])
    
    static var previews: some View {
        DayForecastView(dailyForecast: forecast.daily.first!, timezoneOffset: 0)
            .preferredColorScheme(.dark)
    }
}
