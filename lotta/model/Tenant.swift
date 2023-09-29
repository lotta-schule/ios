//
//  Tenant.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 19/09/2023.
//
import Foundation
import SwiftUI
import LottaCoreAPI

final class Tenant {
    var id: ID
    
    var title: String
    
    var slug: String
    
    var customTheme = [String: String]()
    
    var files = [LottaFile]()
    
    var users = [User]()
    
    var backgroundImageFileId: String?
    
    var logoImageFileId: String?
    
    init(id: String, title: String, slug: String, customTheme: Json? = nil, backgroundImageFileId: String? = nil, logoImageFileId: String? = nil) {
        self.id = id
        self.title = title
        self.slug = slug
        self.backgroundImageFileId = backgroundImageFileId
        self.logoImageFileId = logoImageFileId
        if let customTheme = customTheme {
            switch customTheme {
            case .dictionary(let themeDict):
                for (key, value) in themeDict {
                    if let value = value as? String {
                        self.customTheme[key] = value
                    }
                }
            default:
                print("Unexpected theme \(customTheme)")
            }
        }
    }
    
    convenience init(from graphqlResult: GetTenantQuery.Data.Tenant) {
        self.init(
            id: graphqlResult.id!,
            title: graphqlResult.title!,
            slug: graphqlResult.slug!,
            customTheme: graphqlResult.configuration?.customTheme,
            backgroundImageFileId: graphqlResult.configuration?.backgroundImageFile?.id,
            logoImageFileId: graphqlResult.configuration?.logoImageFile?.id
        )
    }
    
    func getThemeColor(forKey key: String) -> Color? {
        guard let value = self.customTheme[key] else {
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
                print("\(key): \(String(describing: color))")
                return color
            }
        }
        
        return nil
    }
    
}

extension Tenant: Equatable {
    static func == (lhs: Tenant, rhs: Tenant) -> Bool {
        return lhs.slug == rhs.slug && lhs.id == rhs.id
    }
}
