//
//  Locations.swift
//  Weather
//
//  Created by jonathan saville on 06/06/2024.
//

import Foundation
import ComposableArchitecture

enum Flag {
    case showVideo
    case showCurrentLocation
}

@Reducer
struct Locations {
    
    @ObservableState
    struct State: Equatable {
        
        @Shared (.appStorage("showVideo")) var showVideo = false
        @Shared (.appStorage("showCurrentLocation")) var showCurrentLocation = false
        @Presents var alert: AlertState<Action>?
        
        var locations: [CDLocation] = []
        var _itemsUpdated = false
    }

    enum Action: Equatable {
        // UI actions
        case onAppear
        case doneButtonTapped
        case searchTapped

        case toggleShowCurrentLocation(isOn: Bool)
        case toggleShowVideo(isOn: Bool)
        case deleteLocation(at: Int)
        case moveLocation(from: Int, to: Int)
        
        case alert(PresentationAction<Action>)
        case alertConfirmUpdateTapped
        
        // DELEGATE actions
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case close(_ locationsUpdated: Bool)
        }
    }

    var body: some ReducerOf<Self> {
        
        @Dependency(\.persistanceManager) var persistanceManager
        @Dependency(\.clLocationManager) var clLocationManager

        Reduce { state, action in
            switch action {
                
            case .onAppear:
                state.locations = persistanceManager.locations
                
            case .searchTapped:
                state.alert = AlertState(
                    title: TextState("Update locations"),
                    message: TextState("Location search is not yet implemented. Do you wish to update your locations with the set of test locations?"),
                    primaryButton: .destructive(TextState("Update"), action: .send(Action.alertConfirmUpdateTapped)),
                    secondaryButton: .cancel(TextState("Cancel"))
                )
                
            case .doneButtonTapped:
                let didUpdateItems = state._itemsUpdated
                if didUpdateItems {
                    state.locations = persistanceManager.locations // see comment for .moveLocation action
                }
                return .run() { send in await send(.delegate(.close(didUpdateItems))) }

            case .toggleShowCurrentLocation(let isOn):
                state.showCurrentLocation = isOn
                state.locations = persistanceManager.locations
                state._itemsUpdated = true
                if isOn {
                    clLocationManager.requestWhenInUseAuthorization()
                }

            case .toggleShowVideo(let isOn):
                state.showVideo = isOn
                state.locations = persistanceManager.locations
                state._itemsUpdated = true
                
            case .deleteLocation(let index):
                if let location = state.locations[safe: index] {
                    persistanceManager.deleteLocationFor(location.uuid)
                    state.locations = persistanceManager.locations
                    state._itemsUpdated = true
                }
                
            case .moveLocation(let from, let to):
                persistanceManager.moveLocationFrom(from, to: to)
                // Attempting to update state.locations here causes the animation to slow down horribly (don't know why). But if we do not
                // update state.locations with the re-order, then on dismissal of the sheet, the order is displayed incorrectly (as the
                // original order). But fortunately we can update state.locations on dismissal and the rendering of the animation displays
                // the correct order.
                state._itemsUpdated = true

            case .alert(let action):
                switch action {
                case .presented(.alertConfirmUpdateTapped):
                    persistanceManager.loadTestData()
                    state.locations = persistanceManager.locations
                    state._itemsUpdated = true
                default: break
                }
                state.alert = nil

            default: break
            }
            return .none
        }
    }
}
