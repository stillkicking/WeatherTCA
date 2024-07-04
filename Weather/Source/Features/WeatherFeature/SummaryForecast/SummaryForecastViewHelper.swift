//
//  SummaryForecastViewHelper.swift
//  Weather
//
//  Created by jonathan saville on 19/06/2024.
//

struct SummaryForecastViewHelper: Equatable {
    static let numElementsPerScreen = 5
    
    static func scrollLeftTapped(with index: Int?) -> Int {
        max(0, (index ?? 0) - numElementsPerScreen)
    }
    
    static func scrollRightTapped(with index: Int?, elementCount: Int) -> Int {
        min(elementCount - numElementsPerScreen, (index ?? 0) + numElementsPerScreen)
    }
    
    static func isLeftButtonEnabled(forIndex index: Int?) -> Bool {
        (index ?? 0) > 0
    }
    
    static func isRightButtonEnabled(forIndex index: Int?, elementCount: Int) -> Bool {
        (index ?? 0) + numElementsPerScreen < elementCount
    }
}
