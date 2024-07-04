//
//  PrivacyPolicy.swift
//  Weather
//
//  Created by jonathan saville on 13/06/2024.
//

import ComposableArchitecture

@Reducer
struct PrivacyPolicy {
 
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable { case dummy }

    var body: some ReducerOf<Self> {
        Reduce { state, action in .none }
    }
}

import SwiftUI

struct PrivacyPolicyView: View {
    
    var store: StoreOf<PrivacyPolicy>

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(CommonStrings.notYetImplemented)
                .foregroundColor(.defaultText)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                NavBarTitleView(title: "Privacy policy")
            }
        }
    }
}
