//
//  Warnings.swift
//  Weather
//
//  Created by jonathan saville on 29/05/2024.
//

import ComposableArchitecture

struct Warnings: Reducer {
    
    struct State: Equatable {
    }
    
    enum Action {
        case dummy
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dummy:
                return .none
            }
        }
    }
}
