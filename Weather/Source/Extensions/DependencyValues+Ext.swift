//
//  DependencyValues+Ext.swift
//  Weather
//
//  Created by jonathan saville on 03/07/2024.
//

import CoreLocation
import WeatherNetworkingKit
import ComposableArchitecture

extension DependencyValues {
    private enum CLLocationManagerKey: DependencyKey {
        static var liveValue = defaultValue
        static let defaultValue = CLLocationManager()
    }
    public var clLocationManager: CLLocationManager {
        get { self[CLLocationManagerKey.self] }
        set { self[CLLocationManagerKey.self] = newValue }
    }
}

extension DependencyValues {
    private enum PersistanceManagerKey: DependencyKey {
        static var liveValue = defaultValue
        static let defaultValue: PersistenceManagerProtocol = CoreDataManager.shared
    }
    public var persistanceManager: PersistenceManagerProtocol {
        get { self[PersistanceManagerKey.self] }
        set { self[PersistanceManagerKey.self] = newValue }
    }
}

extension DependencyValues {
    private enum NetworkManagerKey: DependencyKey {
        static var liveValue = defaultValue
        static let defaultValue: NetworkManagerProtocol = NetworkManager(apiService: SettingsBundleHelper.shared.isAPIMocked ? MockAPIService() : APIService.shared)
    }
    public var networkManager: NetworkManagerProtocol {
        get { self[NetworkManagerKey.self] }
        set { self[NetworkManagerKey.self] = newValue }
    }
}
