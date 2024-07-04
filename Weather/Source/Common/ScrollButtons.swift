//
//  ScrollButtons.swift
//  Weather
//
//  Created by jonathan saville on 18/06/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ScrollButtons {
        
    @ObservableState
    struct State: Equatable {
        @Shared var isScrollLeftButtonEnabled: Bool
        @Shared var isScrollRightButtonEnabled: Bool
    }
    
    enum Action: Equatable {
        // UI actions
        case scrollLeftButtonTapped
        case scrollRightButtonTapped
   }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in.none }
    }
}

struct ScrollButtonsView: View {
    @Bindable var store: StoreOf<ScrollButtons>
    
    var body: some View {
        HStack() {
            Spacer()
            HStack(spacing: 16) {
                Button(action: { store.send(.scrollLeftButtonTapped) }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(store.state.isScrollLeftButtonEnabled ? .accentColor : .divider)
                }
                .disabled(!store.state.isScrollLeftButtonEnabled)
                
                Rectangle()
                    .fill(Color.divider)
                    .frame(width: 1)

                Button(action: { store.send(.scrollRightButtonTapped) }) {
                    Image(systemName: "chevron.forward")
                        .foregroundColor(store.state.isScrollRightButtonEnabled ? .accentColor : .divider)
                }
                .disabled(!store.state.isScrollRightButtonEnabled)
           }
            .frame(height: 32)
            .padding([.trailing], 24)
        }
    }
}

private extension View {
    func buttonStyle(font: Font, isSelected: Bool, width: CGFloat) -> some View {
        self.font(font)
            .foregroundColor(isSelected ? .backgroundPrimary : .defaultText)
            .frame(width: width)
    }
}

#Preview {
    ScrollButtonsView(
        store: Store(initialState: ScrollButtons.State(isScrollLeftButtonEnabled: Shared(false),
                                                       isScrollRightButtonEnabled: Shared(true))) {
            ScrollButtons() }
    )
}
