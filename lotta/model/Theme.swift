//
//  Theme.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 29/09/2023.
//

import SwiftUI

fileprivate func getColor(forKey key: String, in dict: [String: String]) -> Color? {
    guard let value = dict[key] else {
        return nil
    }
    let fullHexColorRegex = /#([\dA-Za-z]{2})([\dA-Za-z]{2})([\dA-Za-z]{2})([\dA-Za-z]{2})?/
    let simpleHexColorRegex = /#([\dA-Za-z])([\dA-Za-z])([\dA-Za-z])([\dA-Za-z])?/
    if let match = (value.firstMatch(of: fullHexColorRegex) ?? value.firstMatch(of: simpleHexColorRegex)) {
        guard let red = Int(match.1, radix: 16), let green = Int(match.2, radix: 16), let blue = Int(match.3, radix: 16) else {
            return nil
        }
        let opacity: Double? = if let opacityString = match.4 { Double(opacityString) } else { nil }
        if let opacity = opacity {
            return Color(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: opacity / 255)
        } else {
            let color = Color(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
            return color
        }
    }
    
    return nil
}

fileprivate func getNumber(forKey key: String, in dict: [String: String]) -> Int? {
    guard let value = dict[key] else {
        return nil
    }
    let sizeRegex = /(\d*)(px)?/
    if let match = value.firstMatch(of: sizeRegex) {
        return Int(match.1)
    }
    
    return nil
}

struct Theme {
    let primaryColor: Color
    let navigationBackgroundColor: Color
    let errorColor: Color
    let successColor: Color
    let navigationColor: Color
    let disabledColor: Color
    let textColor: Color
    let labelTextColor: Color
    let navigationContrastTextColor: Color
    let primaryContrastTextColor: Color
    let boxBackgroundColor: Color
    let pageBackgroundColor: Color
    let dividerColor: Color
    let highlightColor: Color
    let bannerBackgroundColor: Color
    let accentGreyColor: Color
    
    let spacing: Int
    let borderRadius: Int
    
    static let Default = Theme(
        primaryColor: Color(red: 1.0, green: 0.34, blue: 0.13),
        navigationBackgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2),
        errorColor: Color(red: 1, green: 0, blue: 0),
        successColor: Color(red: 0.04, green: 0.32, blue: 0.15),
        navigationColor: Color(red: 0.2, green: 0.2, blue: 0.2),
        disabledColor: Color(red: 0.38, green: 0.38, blue: 0.38),
        textColor: Color(red: 0.13, green: 0.13, blue: 0.13),
        labelTextColor: Color(red: 0.62, green: 0.62, blue: 0.62),
        navigationContrastTextColor: Color(red: 1, green: 1, blue: 1),
        primaryContrastTextColor: Color(red: 1, green: 1, blue: 1),
        boxBackgroundColor: Color(red: 1, green: 1, blue: 1),
        pageBackgroundColor: Color(red: 0.79, green: 0.8, blue: 0.84),
        dividerColor: Color(red: 0.88, green: 0.88, blue: 0.88),
        highlightColor: Color(red: 0.88, green: 0.88, blue: 0.88),
        bannerBackgroundColor: Color(red: 0.21, green: 0.48, blue: 0.94),
        accentGreyColor: Color(red: 0.89, green: 0.89, blue: 0.89),
        
        spacing: 8,
        borderRadius: 4
    )
    
    init(
        primaryColor: Color,
        navigationBackgroundColor: Color,
        errorColor: Color,
        successColor: Color,
        navigationColor: Color,
        disabledColor: Color,
        textColor: Color,
        labelTextColor: Color,
        navigationContrastTextColor: Color,
        primaryContrastTextColor: Color,
        boxBackgroundColor: Color,
        pageBackgroundColor: Color,
        dividerColor: Color,
        highlightColor: Color,
        bannerBackgroundColor: Color,
        accentGreyColor: Color,
        spacing: Int,
        borderRadius: Int
    ) {
        self.primaryColor = primaryColor
        self.navigationBackgroundColor = navigationBackgroundColor
        self.errorColor = errorColor
        self.successColor = successColor
        self.navigationColor = navigationColor
        self.disabledColor = disabledColor
        self.textColor = textColor
        self.labelTextColor = labelTextColor
        self.navigationContrastTextColor = navigationContrastTextColor
        self.primaryContrastTextColor = primaryContrastTextColor
        self.boxBackgroundColor = boxBackgroundColor
        self.pageBackgroundColor = pageBackgroundColor
        self.dividerColor = dividerColor
        self.highlightColor = highlightColor
        self.bannerBackgroundColor = bannerBackgroundColor
        self.accentGreyColor = accentGreyColor
        self.spacing = spacing
        self.borderRadius = borderRadius
    }
    
    init(themeOverrides: [String: String] = [:]) {
        self.primaryColor = getColor(forKey: "primaryColor", in: themeOverrides) ?? Theme.Default.primaryColor
        self.navigationBackgroundColor = getColor(forKey: "navigationBackgroundColor", in: themeOverrides) ?? Theme.Default.navigationBackgroundColor
        self.errorColor = getColor(forKey: "errorColor", in: themeOverrides) ?? Theme.Default.errorColor
        self.successColor = getColor(forKey: "successColor", in: themeOverrides) ?? Theme.Default.successColor
        self.navigationColor = getColor(forKey: "navigationColor", in: themeOverrides) ?? Theme.Default.navigationColor
        self.disabledColor = getColor(forKey: "disabledColor", in: themeOverrides) ?? Theme.Default.disabledColor
        self.textColor = getColor(forKey: "textColor", in: themeOverrides) ?? Theme.Default.textColor
        self.labelTextColor = getColor(forKey: "labelTextColor", in: themeOverrides) ?? Theme.Default.labelTextColor
        self.navigationContrastTextColor = getColor(forKey: "navigationContrastTextColor", in: themeOverrides) ?? Theme.Default.navigationContrastTextColor
        self.primaryContrastTextColor = getColor(forKey: "primaryContrastTextColor", in: themeOverrides) ?? Theme.Default.primaryContrastTextColor
        self.boxBackgroundColor = getColor(forKey: "boxBackgroundColor", in: themeOverrides) ?? Theme.Default.boxBackgroundColor
        self.pageBackgroundColor = getColor(forKey: "pageBackgroundColor", in: themeOverrides) ?? Theme.Default.pageBackgroundColor
        self.dividerColor = getColor(forKey: "dividerColor", in: themeOverrides) ?? Theme.Default.dividerColor
        self.highlightColor = getColor(forKey: "highlightColor", in: themeOverrides) ?? Theme.Default.highlightColor
        self.bannerBackgroundColor = getColor(forKey: "bannerBackgroundColor", in: themeOverrides) ?? Theme.Default.bannerBackgroundColor
        self.accentGreyColor = getColor(forKey: "accentGreyColor", in: themeOverrides) ?? Theme.Default.accentGreyColor
        self.spacing = getNumber(forKey: "spacing", in: themeOverrides) ?? Theme.Default.spacing
        self.borderRadius = getNumber(forKey: "borderRadius", in: themeOverrides) ?? Theme.Default.borderRadius
    }
    
    
}
