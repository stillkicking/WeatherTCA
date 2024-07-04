//
//  FullForecastOverlay.swift
//  Weather
//
//  Created by jonathan saville on 21/06/2024.
//

import ComposableArchitecture
import WeatherNetworkingKit

@Reducer
struct FullForecastOverlay {

    @ObservableState
    struct State: Equatable {
        var scrollButtonsState: ScrollButtons.State
        @Presents var alert: AlertState<Action>?

        @Shared var isScrollLeftButtonEnabled: Bool
        @Shared var isScrollRightButtonEnabled: Bool
        
        init(isScrollLeftButtonEnabled: Shared<Bool>,
             isScrollRightButtonEnabled: Shared<Bool>) {
            _isScrollLeftButtonEnabled = isScrollLeftButtonEnabled
            _isScrollRightButtonEnabled = isScrollRightButtonEnabled
             scrollButtonsState = ScrollButtons.State(isScrollLeftButtonEnabled: _isScrollLeftButtonEnabled,
                                                     isScrollRightButtonEnabled: _isScrollRightButtonEnabled)
        }
    }
    
    enum Action: Equatable {
        case scrollButtonsState(ScrollButtons.Action)
        case notImplemented
        case alert(PresentationAction<Action>)
    }

    var body: some ReducerOf<Self> {
        
        Scope(state: \.scrollButtonsState, action: /Action.scrollButtonsState) {
            ScrollButtons()
        }

        Reduce { state, action in
            switch action {
            case .scrollButtonsState:
                break
                
            case .notImplemented:
                state.alert = AlertState(
                    title: { TextState(CommonStrings.notYetImplemented) },
                    actions: { ButtonState(role: .cancel, label: { TextState("OK") }) }
                )
                
            case .alert(let action):
                if action == .dismiss {
                    state.alert = nil
                }
            }
            return .none
        }
    }
}
