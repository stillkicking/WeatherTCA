//
//  Forecast+Extension.swift
//  Weather
//
//  Created by jonathan saville on 15/06/2024.
//

import WeatherNetworkingKit

extension Forecast {
    
    var displayLocationName: String {
        location?.fullName ?? "-"
    }
}
