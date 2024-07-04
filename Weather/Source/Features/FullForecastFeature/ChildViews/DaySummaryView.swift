//
//  DaySummaryView.swift
//  Weather
//
//  Created by jonathan saville on 10/10/2023.
//

import SwiftUI
import CoreLocation
import WeatherNetworkingKit

struct DaySummaryView: View {
    let forecast: Forecast
    let selectedDay: Int
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text(forecast.daily[safe: selectedDay]?.displayable.first?.description ?? "")
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                Text("Day")
                    .padding(.leading)
                Text(forecast.daily[safe: selectedDay]?.temperature.max.temperatureString ?? "-")
                    .font(.veryLargeFontBold)
                Text("/")
                    .font(.veryLargeFont)
                Text(forecast.daily[safe: selectedDay]?.temperature.min.temperatureString ?? "-")
                    .font(.veryLargeFontBold)
                Text("Night")
               Spacer()
            }
        }
    }
}

struct DaySummaryView_Previews: PreviewProvider {
    static let location = Location(coordinates: CLLocationCoordinate2D(latitude: 41.8933203, longitude: 12.4829321), name: "Rome (Lazio)")
    static let forecast: Forecast = try! MockAPIService().getForecast(for: location.coordinates, from: [location])
    
    static var previews: some View {
        DaySummaryView(forecast: forecast, selectedDay: 5)
            .preferredColorScheme(.dark)
    }
}
