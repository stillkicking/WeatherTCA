//
//  Weather.swift
//  Weather
//
//  Created by jonathan saville on 28/05/2024.
//
import Foundation
import CoreLocation
import Combine
import ComposableArchitecture
import WeatherNetworkingKit

@Reducer
struct Weather {
 
    @ObservableState
    struct State: Equatable {
        enum Loading: Equatable {
            case idle, loading, loaded, error(String)
        }
        @Shared (.appStorage("showVideo")) var showVideo = false
        @Shared (.appStorage("showCurrentLocation")) var showCurrentLocation = false
        @Shared var selectedDay: Int
 
        var loading: Loading = .idle
        var forecasts: IdentifiedArrayOf<SummaryForecast.State> = []
        
        @Presents public var settingsState: Settings.State?
        @Presents public var locationsState: Locations.State?
        @Presents public var fullForecastState: FullForecast.State?

        init(showVideo: Bool = false,
             settingsState: Settings.State? = nil,
             locationsState: Locations.State? = nil,
             fullForecastState: FullForecast.State? = nil) {
            self.settingsState = settingsState
            self.locationsState = locationsState
            self.fullForecastState = fullForecastState
            _selectedDay = Shared(0)
        }
    }
    
    enum Action {
        // UI actions
        case onAppear
        case reloadForecastsRequested
        case settingsButtonTapped
        case editButtonTapped
        case forecasts(IdentifiedActionOf<SummaryForecast>)
        case fullForecastState(PresentationAction<FullForecast.Action>)
        case settingsState(PresentationAction<Settings.Action>)
        case locationsState(PresentationAction<Locations.Action>)
        
        // INTERNAL actions
        case _loadForecasts
        case _receivedForecasts([Forecast])
        case _apiError(Error)
    }
    
    var body: some ReducerOf<Self> {
        
        @Dependency(\.persistanceManager) var persistanceManager
        @Dependency(\.networkManager) var networkManager

        Reduce { state, action in

            switch action {
                
            // UI actions
            case .onAppear:
                if state.loading == .idle {
                    return .run() { send in await send(._loadForecasts) }
                }
                
            case .reloadForecastsRequested:
                if state.loading != .loading {
                    return .run() { send in await send(._loadForecasts) }
                }
                
           case .settingsButtonTapped:
                state.settingsState = Settings.State()
                
            case .editButtonTapped:
                state.locationsState = Locations.State()

           // INTERNAL actions
            case ._loadForecasts:
                state.loading = .loading
                let locations = persistanceManager.locations.map { Location(from: $0) }
                let showCurrentLocation = state.showCurrentLocation

                return .run() { send in
                    do {
                        let response = try await networkManager.getForecasts(for: locations, includeCurrentLocation: showCurrentLocation)
                        await send(._receivedForecasts(response))
                    }
                    catch (let error) {
                        await send(._apiError(error)) // cannot set state here (in concurrently-executing code) - must return an effect instead
                    }
                }

            case let ._receivedForecasts(forecasts):
                let forecastStates = forecasts.map { SummaryForecast.State(forecast: $0) }
                state.forecasts = .init(uniqueElements: forecastStates)
                state.loading = .loaded
            
            case let ._apiError(error):
                state.loading = .error(error.localizedDescription)

            // DELEGATE actions
            case .forecasts(.element(let id, .delegate(.dayTapped(let day)))):
                if let forecast: Forecast = state.forecasts[id: id]?.forecast {
                    state.fullForecastState = FullForecast.State(forecast, selectedDay: day)
                }
            
            case .forecasts(.element(let id, .delegate(.fullForecastTapped))):
                if let forecast: Forecast = state.forecasts[id: id]?.forecast {
                    state.fullForecastState = FullForecast.State(forecast, selectedDay: 0)
                }
                
            case .locationsState(.presented(.delegate(.close(let locationsUpdated)))):
                state.locationsState = nil
                if locationsUpdated, state.loading != .loading {
                   return .run() { send in await send(._loadForecasts) }
                }

            default:
                break
            }
            return .none
        }
        .ifLet( \.$settingsState, action: /Action.settingsState) {
            Settings()
        }
        .ifLet( \.$locationsState, action: /Action.locationsState) {
            Locations()
        }
        .ifLet( \.$fullForecastState, action: /Action.fullForecastState) {
            FullForecast()
        }
        .forEach(\.forecasts, action: \.forecasts) {
            SummaryForecast()
        }
    }
}
