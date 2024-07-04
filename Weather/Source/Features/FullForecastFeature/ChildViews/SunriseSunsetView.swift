//
//  SunriseSunsetView.swift
//  Weather
//
//  Created by jonathan saville on 09/11/2023.
//

import SwiftUI
import CoreLocation
import WeatherNetworkingKit

struct SunriseSunsetView: View {
    let forecast: Forecast
    let selectedDay: Int
    
    let sunriseDate: Date?
    let sunsetDate: Date?
    let sunriseColor = Color.yellow
    let sunsetColor = Color.red

    init(forecast: Forecast,
         selectedDay: Int) {
        self.forecast = forecast
        self.selectedDay = selectedDay
        sunriseDate = forecast.daily[safe: selectedDay]?.sunrise
        sunsetDate = forecast.daily[safe: selectedDay]?.sunset
    }

    var body: some View {
        VStack() {
            
            Text("Sunrise | Sunset")
                .font(.largeFontBold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack() {
                Image(systemName: "sunrise.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32.0)
                    .foregroundColor(sunriseColor)
                Spacer()
                Image(systemName: "sunset.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32.0)
                    .foregroundColor(sunsetColor)
            }
            .padding(.top, 16)
            
            Divider()
                .frame(height: 4)
                .background(LinearGradient(gradient: Gradient(colors: [sunriseColor, sunsetColor]), startPoint: .leading, endPoint: .trailing))
                .padding(.top, -10) // ensure we cover the 'horizon' of the icons
            
            HStack() {
                Text(sunriseDate?.formattedTime(forecast.timezoneOffset) ?? "-")
                Spacer()
                Text(sunsetDate?.formattedTime(forecast.timezoneOffset) ?? "-")
            }
        }
    }
}

struct SunriseSunsetView_Previews: PreviewProvider {
    static let location = Location(coordinates: CLLocationCoordinate2D(latitude: 41.8933203, longitude: 12.4829321), name: "Rome (Lazio)")
    static let forecast: Forecast = try! MockAPIService().getForecast(for: location.coordinates, from: [location])
    
    static var previews: some View {
        SunriseSunsetView(forecast: forecast, selectedDay: 5)
            .preferredColorScheme(.dark)
    }
}
