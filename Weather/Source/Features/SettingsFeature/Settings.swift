//
//  Settings.swift
//  Weather
//
//  Created by jonathan saville on 05/06/2024.
//

import ComposableArchitecture

@Reducer
struct Settings {

    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case notifications(Notifications)
        case advertising(Advertising)
        case acknowledgements(Acknowledgements)
        case customize(Customize)
        case privacyPolicy(PrivacyPolicy)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        @Presents var alert: AlertState<Action>?
    }
    
    enum Action: Equatable {
        case closeButtonTapped
        case notImplemented
        case alert(PresentationAction<Action>)
        case path(StackActionOf<Path>)
    }

    var body: some ReducerOf<Self> {
            
        @Dependency(\.dismiss) var dismiss

        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                Task { await dismiss() }

            case .notImplemented:
                state.alert = okAlert(CommonStrings.notYetImplemented)
                
            case .alert(.dismiss):
                state.alert = nil

            default:
                break
            }
            return .none
        }
        .forEach(\.path, action: \.path)
    }
    
    private func okAlert(_ title: String) -> AlertState<Action> {
        AlertState(
            title: { TextState(title) },
            actions: { ButtonState(role: .cancel, label: { TextState("OK") }) }
        )
    }
}
