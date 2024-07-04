//
//  NavBarTitleView.swift
//  Weather
//
//  Created by jonathan saville on 26/04/2024.
//

import SwiftUI

struct NavBarTitleView: View {

    let title: String
    let imageName: String?

    init(title: String,
         imageName: String? = nil) {
        self.title = title
        self.imageName = imageName
    }

    var body: some View {
        if let imageName = imageName {
            Label {
                Text(title)
                    .navBarTitle()
            } icon: {
                Image(imageName)
                    .renderingMode(.template)
                    .resizable().frame(width: 20, height: 20)
                    .foregroundColor(.accentColor)
            }
            .labelStyle(.titleAndIcon)
        } else {
            Text(title)
                .navBarTitle()
        }
    }
    
    static var weather: NavBarTitleView {
        Self.init(title: "Weather", imageName: "navBarIcon")
    }
}

public extension View {
    func navBarTitle() -> some View {
        self.modifier( NavBarTitleModifier() )
     }
}

private struct NavBarTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
           .font(.headline)
           .foregroundColor(.defaultText)
    }
}

struct NavBarTitleView_Previews: PreviewProvider {

    static var previews: some View {
        NavBarTitleView(title: "Weather", imageName: "navBarIcon")
            .background(Color.black)
    }
}
