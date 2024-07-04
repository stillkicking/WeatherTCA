//
//  SlidingSelector.swift
//  Weather
//
//  Created by jonathan saville on 18/06/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SlidingSelector {
        
    @ObservableState
    struct State: Equatable {
        let titles: [String]
        var selectedIndex: Int = 0
        var offset: CGFloat = 0
        @Shared var selectorState: SelectorState // would be better if I could genericise this - but how to make an enum generic?
                                                 // or maybe use a simple [String] instead?
    }
    
    enum Action: Equatable {
        case selectedIndex(_ value: Int)
        case offset(_ value: CGFloat)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .selectedIndex(let value):
                state.selectedIndex = value
                state.selectorState = SelectorState(rawValue: value) ?? .precipitation
            case .offset(let value):
                state.offset = value
            }
            return .none
        }
    }
}

struct SlidingSelectorView: View {
    @Bindable var store: StoreOf<SlidingSelector>
    
    let font = Font.defaultFont
    let fontLineHeight = Font.defaultFontLineHeight
    let padding: CGFloat = 8
    let cornerRadius: CGFloat = 8
    let animationDuration = 0.15

    var selectorFractionalWidth: CGFloat { 1 / CGFloat(store.state.titles.count) }

    var body: some View {
    
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.backgroundSecondary)
            
                .overlay {
                    HStack(spacing: 0) {
                        // Having a full-width HStack for the overlay means I can default the offset to 0 without knowing
                        // the rendered width (if I just use a RoundeRectangle without an HStack, the overlay would
                        // initially be rendered centrally).
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width * selectorFractionalWidth)
                        ForEach(0..<store.state.titles.count-1, id: \.self) { i in
                            Rectangle()
                                .fill(.clear)
                                .frame(width: geometry.size.width * selectorFractionalWidth)
                        }
                    }
                    .offset(x: store.state.offset, y: 0)
                }

                .overlay {
                    HStack(spacing: 0) {
                        ForEach(0..<store.state.titles.count, id: \.self) { i in
                            Button {
                                store.send(.selectedIndex(i))
                                let offset = i == 0 ? 0 : geometry.size.width * CGFloat(i) * selectorFractionalWidth
                                let _ = withAnimation(.linear(duration: animationDuration)) {
                                    store.send(.offset(offset))
                                }
                            } label: {
                               Text(store.state.titles[safe: i] ?? "-")
                                  .buttonStyle(font: font, isSelected: store.state.selectedIndex == i, width: geometry.size.width * selectorFractionalWidth)
                            }
                            .disabled(store.state.selectedIndex == i)
                       }
                    }
                }
        }
        .frame(height: fontLineHeight + (padding * 2))
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
    SlidingSelectorView(
        store: Store(initialState: SlidingSelector.State(titles: ["A", "B", "C"], selectorState: Shared(SelectorState.precipitation))) {
            SlidingSelector()
        }
    )
}
