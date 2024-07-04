//
//  SummaryForecast.swift
//  Weather
//
//  Created by jonathan saville on 05/06/2024.
//

import Foundation
import ComposableArchitecture
import WeatherNetworkingKit

@Reducer
struct SummaryForecast {
    
    let numElementsPerScreen = 5
    
    @ObservableState
    struct State: Equatable, Identifiable {
        
        let id = UUID()
        let forecast: Forecast
        var scrollButtonsState: ScrollButtons.State
        
        /// The view must have write access to this property, which is provided to the view
        /// by Action.scrollIndex and .sending(_ action: CaseKeyPath<Action, Value>).
        var scrollIndex: Int? = 0
        
        @Shared var isScrollLeftButtonEnabled: Bool
        @Shared var isScrollRightButtonEnabled: Bool
        
        init(forecast: Forecast) {
            self.forecast = forecast
            _isScrollLeftButtonEnabled = Shared(false)
            _isScrollRightButtonEnabled = Shared(false)
            scrollButtonsState = ScrollButtons.State(isScrollLeftButtonEnabled: _isScrollLeftButtonEnabled,
                                                     isScrollRightButtonEnabled: _isScrollRightButtonEnabled)
        }
    }
    
    enum Action : Equatable {
        // UI actions
        case onAppear
        case dayTapped(_ day: Int)
        case fullForecastTapped
        case scrollIndex(value: Int?)
        
        case scrollButtonsState(ScrollButtons.Action)
        
        // DELEGATE actions
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case dayTapped(_ day: Int)
            case fullForecastTapped
        }
    }

    var body: some ReducerOf<Self> {

        Reduce { state, action in
            switch action {
                
            // UI actions
            case .onAppear:
                return .run() { send in await send(.scrollIndex(value: 0)) }
                
            case .dayTapped(let day):
                return  .run() { send in await send(.delegate(.dayTapped(day))) }
                
            case .fullForecastTapped:
                return  .run() { send in await send(.delegate(.fullForecastTapped)) }

            case .scrollIndex(let value):
                state.scrollIndex = value
                state.isScrollLeftButtonEnabled = SummaryForecastViewHelper.isLeftButtonEnabled(forIndex: value)
                state.isScrollRightButtonEnabled = SummaryForecastViewHelper.isRightButtonEnabled(forIndex: value, elementCount: state.forecast.daily.count)
                
            // DELEGATE actions
            case .scrollButtonsState(.scrollLeftButtonTapped):
                state.scrollIndex = SummaryForecastViewHelper.scrollLeftTapped(with: state.scrollIndex)

            case .scrollButtonsState(.scrollRightButtonTapped):
                state.scrollIndex = SummaryForecastViewHelper.scrollRightTapped(with: state.scrollIndex, elementCount: state.forecast.daily.count)

            case .delegate:
                break
            }
            return .none
        }
    }
}
