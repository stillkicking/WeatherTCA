//
//  WeatherApp.swift
//  Weather
//
//  Created by jonathan saville on 19/03/2024.
//

import SwiftUI
import CoreLocation
import ComposableArchitecture
import WeatherNetworkingKit

@main
struct WeatherApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(initialState: Root.State()) {
                    Root()
                }
            )
        }
    }
}
