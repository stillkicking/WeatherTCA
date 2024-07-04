//
//  Location.swift
//  Weather
//
//  Created by jonathan saville on 03/07/2024.
//

import CoreLocation
import WeatherNetworkingKit

public extension Location {

    convenience init(from cdLocation: CDLocation) {
        self.init(coordinates: CLLocationCoordinate2D(latitude: Double(truncating: cdLocation.latitude),
                                                      longitude: Double(truncating: cdLocation.longitude)),
                  name: cdLocation.name,
                  country: cdLocation.country,
                  state: cdLocation.state)
    }
}
