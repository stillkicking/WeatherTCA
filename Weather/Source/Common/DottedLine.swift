//
//  DottedLine.swift
//  Weather
//
//  Created by jonathan saville on 23/10/2023.
//

import SwiftUI

struct DottedLine: Shape {
        
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        return path
    }
}
