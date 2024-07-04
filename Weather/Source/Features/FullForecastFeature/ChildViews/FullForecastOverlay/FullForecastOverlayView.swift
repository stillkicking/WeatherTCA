//
//  FullForecastOverlayView.swift
//  Weather
//
//  Created by jonathan saville on 21/06/2024.
//

import SwiftUI
import CoreLocation
import ComposableArchitecture
import WeatherNetworkingKit

struct FullForecastOverlayView: View {
    @Bindable var store: StoreOf<FullForecastOverlay>
   
    static let height: CGFloat = topViewHeight + feedbackViewHeight + bottomViewHeight
    private static let topViewHeight: CGFloat = 48
    private static let feedbackViewHeight: CGFloat = 76
    private static let bottomViewHeight: CGFloat = 44

    var body: some View {
        VStack(spacing: 0) {

            // topView
            ScrollButtonsView(store: store.scope(state: \.scrollButtonsState, action: \.scrollButtonsState))
            .padding([.top, .bottom], 8)
            .background(Color.backgroundPrimary)
            .clipShape(.rect( bottomLeadingRadius: RoundedCorners.defaultRadius,
                              bottomTrailingRadius: RoundedCorners.defaultRadius))
            .frame(height: Self.topViewHeight)

            // feedbackView
            HStack() {
                Text("How accurate do you find the forecast?")
                 .padding(8)
                Spacer()
                Button() {
                    store.send(.notImplemented)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color.accentColor)
                }
            }
            .padding(8)
            .background(Color.backgroundPrimary)
            .foregroundColor(Color.accentColor)
            .cornerRadius(RoundedCorners.defaultRadius)
            .frame(height: Self.feedbackViewHeight)

            // bottomView
            HStack() {
                Text("Wind Forecast")
                    .padding(.leading, 8)
                    .font(.largeFontBold)
                Spacer()
                Button() {
                    store.send(.notImplemented)
                } label: {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color.accentColor)
                }
            }
            .padding([.leading, .trailing], 8)
            .padding([.top, .bottom], 12)
            .background(Color.backgroundPrimary)
            .clipShape(.rect( topLeadingRadius: RoundedCorners.defaultRadius,
                              topTrailingRadius: RoundedCorners.defaultRadius))
            .frame(height: Self.bottomViewHeight)
        }
        .alert( store: self.store.scope(state: \.$alert, action: \.alert))
    }
}
