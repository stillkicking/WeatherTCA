//
//  WarningsView.swift
//  Weather
//
//  Created by jonathan saville on 29/05/2024.
//

import SwiftUI
import ComposableArchitecture

struct WarningsView: View {
    let store: StoreOf<Warnings>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack() {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.backgroundGradientFrom,
                                                               .backgroundGradientTo]), startPoint: .bottom, endPoint: .top)
                    Text(CommonStrings.notYetImplemented)
                        .foregroundColor(.defaultText)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.navbarBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Weather warnings").font(.largeFont)
                            .foregroundColor(.defaultText)
                    }
                }
            }
        }
    }
}

#Preview {
    WarningsView(
        store: Store(initialState: Warnings.State()) {
            Warnings()
        }
    )
}
