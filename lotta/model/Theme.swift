//
//  Theme.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 29/09/2023.
//

import SwiftUI

fileprivate func getColor(forKey key: String, in dict: [String: String]) -> ThemeColor? {
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
            return ThemeColor(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: opacity / 255)
        } else {
            let color = ThemeColor(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
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
    let primaryColor: ThemeColor
    let navigationBackgroundColor: ThemeColor
    let errorColor: ThemeColor
    let successColor: ThemeColor
    let navigationColor: ThemeColor
    let disabledColor: ThemeColor
    let textColor: ThemeColor
    let labelTextColor: ThemeColor
    let navigationContrastTextColor: ThemeColor
    let primaryContrastTextColor: ThemeColor
    let boxBackgroundColor: ThemeColor
    let pageBackgroundColor: ThemeColor
    let dividerColor: ThemeColor
    let highlightColor: ThemeColor
    let bannerBackgroundColor: ThemeColor
    let accentGreyColor: ThemeColor
    
    let spacing: Int
    let borderRadius: Int
    
    static let Default = Theme(
        primaryColor: ThemeColor(red: 1.0, green: 0.34, blue: 0.13),
        navigationBackgroundColor: ThemeColor(red: 0.2, green: 0.2, blue: 0.2),
        errorColor: ThemeColor(red: 1, green: 0, blue: 0),
        successColor: ThemeColor(red: 0.04, green: 0.32, blue: 0.15),
        navigationColor: ThemeColor(red: 0.2, green: 0.2, blue: 0.2),
        disabledColor: ThemeColor(red: 0.38, green: 0.38, blue: 0.38),
        textColor: ThemeColor(red: 0.13, green: 0.13, blue: 0.13),
        labelTextColor: ThemeColor(red: 0.62, green: 0.62, blue: 0.62),
        navigationContrastTextColor: ThemeColor(red: 1, green: 1, blue: 1),
        primaryContrastTextColor: ThemeColor(red: 1, green: 1, blue: 1),
        boxBackgroundColor: ThemeColor(red: 1, green: 1, blue: 1),
        pageBackgroundColor: ThemeColor(red: 0.79, green: 0.8, blue: 0.84),
        dividerColor: ThemeColor(red: 0.88, green: 0.88, blue: 0.88),
        highlightColor: ThemeColor(red: 0.88, green: 0.88, blue: 0.88),
        bannerBackgroundColor: ThemeColor(red: 0.21, green: 0.48, blue: 0.94),
        accentGreyColor: ThemeColor(red: 0.89, green: 0.89, blue: 0.89),
        
        spacing: 8,
        borderRadius: 4
    )
    
    init(
        primaryColor: ThemeColor,
        navigationBackgroundColor: ThemeColor,
        errorColor: ThemeColor,
        successColor: ThemeColor,
        navigationColor: ThemeColor,
        disabledColor: ThemeColor,
        textColor: ThemeColor,
        labelTextColor: ThemeColor,
        navigationContrastTextColor: ThemeColor,
        primaryContrastTextColor: ThemeColor,
        boxBackgroundColor: ThemeColor,
        pageBackgroundColor: ThemeColor,
        dividerColor: ThemeColor,
        highlightColor: ThemeColor,
        bannerBackgroundColor: ThemeColor,
        accentGreyColor: ThemeColor,
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
    
    init() {
        self.init(themeOverrides: [:])
    }
    
}

extension Theme: Codable {}
