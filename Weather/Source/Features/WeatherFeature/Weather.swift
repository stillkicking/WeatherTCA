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
        enum Loading {
            case idle, loading, loaded
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
        case _loadForecastsResponse(Result<[Forecast], any Error>)
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
                return .publisher() {
                    let locations = persistanceManager.locations.map { Location(from: $0) }
                    return networkManager.forecastPublisher(for: locations,
                                                            includeCurrentLocation: state.showCurrentLocation)
                        .map { Action._loadForecastsResponse( $0 )}
                }

            case let ._loadForecastsResponse(response):
                switch response {
                case let .success(data):
                    let forecastStates = data.map { SummaryForecast.State(forecast: $0) }
                    state.forecasts = .init(uniqueElements: forecastStates)
                case .failure: // (error):
                    // TBD display error to user
                    break
                }
                state.loading = .loaded
                
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
