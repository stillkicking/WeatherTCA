//
//  Advertising.swift
//  Weather
//
//  Created by jonathan saville on 14/06/2024.
//

import ComposableArchitecture

@Reducer
struct Advertising {
    
    @ObservableState
    struct State: Equatable {}
    
    enum Action: Equatable { case dummy }

    var body: some ReducerOf<Self> {
        Reduce { state, action in .none }
    }
}

import SwiftUI

struct AdvertisingView: View {
    
    var store: StoreOf<Advertising>

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(CommonStrings.notYetImplemented)
                .foregroundColor(.defaultText)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                NavBarTitleView(title: "Advertising")
            }
        }
    }
}
