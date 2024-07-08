//
//  NetworkManager.swift
//  Weather
//
//  Created by jonathan saville on 21/03/2024.
//
//  NOTE - when the API is mocked, ensure that the simulator's location (set in Features->Location) is set to 'Apple' as that is the mocked current location.
//

import CoreLocation
import WeatherNetworkingKit

public protocol NetworkManagerProtocol {
    func getForecasts(for locations: [Location], includeCurrentLocation: Bool) async throws -> [Forecast]
}

public class NetworkManager: NetworkManagerProtocol {
    
    let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    public func getForecasts(for locations: [Location],
                             includeCurrentLocation: Bool) async throws -> [Forecast] {
        var _locations = locations
        
        if includeCurrentLocation,
           let currentLocation = getCurrentLocation(withName: CommonStrings.currentLocation) {
            _locations.insert(currentLocation, at: 0)
        }

#if DEBUG
        try await Task.sleep(until: .now + .seconds(0.5)) // DEV-ONLY, force a delay for dev testing to allow busy indicator to show
#endif
        return try await apiService.getForecastsAsyncAwait(for: _locations)
    }

    private func getCurrentLocation(withName name: String) -> Location? {
        let locationManager = CLLocationManager()
        
        switch CLLocationManager().authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            guard let currentLocation = locationManager.location else { return nil }
            return Location(coordinates: currentLocation.coordinate, name: name)
        default:
            return nil
        }
    }
}
