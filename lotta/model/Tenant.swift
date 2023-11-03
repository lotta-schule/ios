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
    
    var customTheme = Theme()
    
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
                var themeOverrides: [String:String] = [:]
                for (key, value) in themeDict {
                    if let value = value as? String {
                        themeOverrides[key] = value
                    }
                }
                self.customTheme = Theme(themeOverrides: themeOverrides)
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
    
}

extension Tenant: Equatable {
    static func == (lhs: Tenant, rhs: Tenant) -> Bool {
        return lhs.slug == rhs.slug && lhs.id == rhs.id
    }
}

extension Tenant: Codable {}
