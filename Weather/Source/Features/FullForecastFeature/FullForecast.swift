//
//  FullForecast.swift
//  Weather
//
//  Created by jonathan saville on 15/06/2024.
//

import Foundation
import ComposableArchitecture
import WeatherNetworkingKit

@Reducer
struct FullForecast {

    @ObservableState
    struct State: Equatable {
        let forecast: Forecast
        var selectedDay: Int
        
        var scrollButtonsState: ScrollButtons.State
        var slidingSelectorState: SlidingSelector.State
        var fullForecastOverlayState: FullForecastOverlay.State
        
        /// The view must have write access to this property, which is provided to the view
        /// by Action.hourlyScrollIndex and .sending(_ action: CaseKeyPath<Action, Value>).
        var hourlyScrollIndex: Int?
 
        /// The view must have write access to this property, which is provided to the view
        /// by Action.dailyScrollIndex and .sending(_ action: CaseKeyPath<Action, Value>).
        var dailyScrollIndex: Int?

        var isAnimationEnabled = false
        
        let viewHelper: FullForecastViewHelper
        
        @Shared var isScrollLeftButtonEnabled: Bool
        @Shared var isScrollRightButtonEnabled: Bool
        @Shared var selectorState: SelectorState

        init(_ forecast: Forecast,
             selectedDay: Int) {
            self.forecast = forecast
            self.selectedDay = selectedDay
            _selectorState = Shared(.precipitation)
            _isScrollLeftButtonEnabled = Shared(false)
            _isScrollRightButtonEnabled = Shared(false)
            slidingSelectorState = SlidingSelector.State(titles: SelectorState.titles, selectorState: _selectorState)
            scrollButtonsState = ScrollButtons.State(isScrollLeftButtonEnabled: _isScrollLeftButtonEnabled,
                                                     isScrollRightButtonEnabled: _isScrollRightButtonEnabled)
            fullForecastOverlayState = FullForecastOverlay.State(isScrollLeftButtonEnabled: _isScrollLeftButtonEnabled,
                                                                 isScrollRightButtonEnabled: _isScrollRightButtonEnabled)
            viewHelper = FullForecastViewHelper(forecast: forecast)
         }
    }
    
    enum Action: Equatable {
        // UI actions
        case onAppear
        case closeButtonTapped
        case dayTapped(_ index: Int)
        case hourlyScrollIndex(_ value: Int?)
        case dailyScrollIndex(_ value: Int?)

        case slidingSelectorState(SlidingSelector.Action)
        case scrollButtonsState(ScrollButtons.Action)
        case fullForecastOverlayState(FullForecastOverlay.Action)
        
        // INTERNAL actions
        case _enableAnimation(_ enabled: Bool)
    }

    var body: some ReducerOf<Self> {
        
        @Dependency(\.dismiss) var dismiss

        Scope(state: \.fullForecastOverlayState, action: /Action.fullForecastOverlayState) {
            FullForecastOverlay()
        }

        Scope(state: \.slidingSelectorState, action: /Action.slidingSelectorState) {
            SlidingSelector()
        }

        Reduce { state, action in
            switch action {
                
            // UI actions
            case .onAppear:
                state.dailyScrollIndex = state.selectedDay
                state.hourlyScrollIndex = state.viewHelper.hourlyScrollIndex(for: state.selectedDay)
                return .run() { send in await send(._enableAnimation(true)) }
                
            case .dayTapped(let day):
                state.selectedDay = day
                state.dailyScrollIndex = day
                state.hourlyScrollIndex = state.viewHelper.hourlyScrollIndex(for: day)
                
            case .closeButtonTapped:
                Task { await dismiss() }
                
            case .hourlyScrollIndex(let value):
                state.hourlyScrollIndex = value
                state.isScrollLeftButtonEnabled = state.viewHelper.isLeftButtonEnabled(forIndex: value)
                state.isScrollRightButtonEnabled = state.viewHelper.isRightButtonEnabled(forIndex: value)
                let newDailyScrollIndex = state.viewHelper.dailyScrollIndex(for: value ?? 0)
                state.selectedDay = newDailyScrollIndex
                // Oddly, to ensure the DailyScrollView actually scrolls, we need to send a .dailyScrollIndex
                // action rather than directly setting the dailyScrollIndex here...
                return .run() { send in await send(.dailyScrollIndex(newDailyScrollIndex)) }

            case .dailyScrollIndex(value: let value):
                state.dailyScrollIndex = value
                
            // INTERNAL actions
            case ._enableAnimation(let enabled):
                state.isAnimationEnabled = enabled
                
            // DELEGATED actions
            case .scrollButtonsState(.scrollLeftButtonTapped),
                 .fullForecastOverlayState(.scrollButtonsState(.scrollLeftButtonTapped)):
                let newHourlyScrollIndex = state.viewHelper.indexForScrollLeft(from: state.hourlyScrollIndex)
                let newDailyScrollIndex = state.viewHelper.dailyScrollIndex(for: newHourlyScrollIndex)
                state.hourlyScrollIndex = newHourlyScrollIndex
                state.dailyScrollIndex = newDailyScrollIndex
                state.selectedDay = newDailyScrollIndex
                
            case .scrollButtonsState(.scrollRightButtonTapped),
                    .fullForecastOverlayState(.scrollButtonsState(.scrollRightButtonTapped)):
                let newHourlyScrollIndex = state.viewHelper.indexForScrollRight(from: state.hourlyScrollIndex)
                let newDailyScrollIndex = state.viewHelper.dailyScrollIndex(for: newHourlyScrollIndex)
                state.hourlyScrollIndex = newHourlyScrollIndex
                state.dailyScrollIndex = newDailyScrollIndex
                state.selectedDay = newDailyScrollIndex

            case .slidingSelectorState:
                break
                
            case .fullForecastOverlayState:
                break
                
            }
            return .none
        }
    }
}

enum SelectorState: Int, CaseIterable {
    case precipitation
    case feelsLike
    
    var title: String {
        switch self {
        case .precipitation: return "Precipitation"
        case .feelsLike: return "Feels like°"
        }
    }
    
    static var titles: [String] {
        var titles: [String] = []
        for state in SelectorState.allCases {
            titles.append(state.title)
        }
        return titles
    }
}
