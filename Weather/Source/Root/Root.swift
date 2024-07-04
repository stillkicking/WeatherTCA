//
//  Root.swift
//  Weather
//
//  Created by jonathan saville on 28/05/2024.
//

import ComposableArchitecture
import WeatherNetworkingKit

struct Root: Reducer {
    
    struct State: Equatable {
    }
    
    enum Action {
        case dummy
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dummy:
                break
            }
            return .none
        }
    }
}
