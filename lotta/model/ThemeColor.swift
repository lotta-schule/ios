//
//  ThemeColor.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 03/11/2023.
//

import Foundation
import SwiftUI

struct ThemeColor {
    let red: CGFloat
    
    let green: CGFloat
    
    let blue: CGFloat
    
    let opacity: CGFloat
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }
    
    func toColor() -> Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension ThemeColor : Codable {}

extension ThemeColor : ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> Color {
        return self.toColor()
    }
}
