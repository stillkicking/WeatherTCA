//
//  NetworkManager.swift
//  Weather
//
//  Created by jonathan saville on 21/03/2024.
//
//  NOTE - when the API is mocked, ensure that the simulator's location (set in Features->Location) is set to 'Apple' as that is the mocked current location.
//

import Combine
import CoreLocation
import WeatherNetworkingKit

public protocol NetworkManagerProtocol {
    func forecastPublisher(for locations: [Location], includeCurrentLocation: Bool) -> AnyPublisher<Result<[Forecast], Error>, Never>
}

public class NetworkManager: NetworkManagerProtocol {
    
    let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    public func forecastPublisher(for locations: [Location],
                                  includeCurrentLocation: Bool) -> AnyPublisher<Result<[WeatherNetworkingKit.Forecast], Error>, Never> {
        var _locations = locations
        
        if includeCurrentLocation,
           let currentLocation = getCurrentLocation(withName: CommonStrings.currentLocation) {
            _locations.insert(currentLocation, at: 0)
        }

        return apiService.getForecasts(locations: _locations)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main ) // DEV-ONLY, force a delay for dev testing to allow busy indicator to show
            .eraseToAnyPublisher()
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
