//
//  Notifications.swift
//  Weather
//
//  Created by jonathan saville on 13/06/2024.
//

import ComposableArchitecture

@Reducer
struct Notifications {
 
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable { case dummy }

    var body: some ReducerOf<Self> {        
        Reduce { state, action in .none }
    }
}

import SwiftUI

struct NotificationsView: View {
    
    var store: StoreOf<Notifications>

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(CommonStrings.notYetImplemented)
                .foregroundColor(.defaultText)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                NavBarTitleView(title: "Notifications")
            }
        }
    }
}
