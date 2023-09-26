//
//  Tenant.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 19/09/2023.
//
import Foundation
import SwiftData
import LottaCoreAPI

@Model
final class Tenant {
    @Attribute(.unique) var id: ID
    
    var title: String
    
    var slug: String
    
    var customTheme = [String: String]()
    
    @Relationship(deleteRule: .cascade, inverse: \LottaFile.tenant) var files = [LottaFile]()
    
    @Relationship(deleteRule: .cascade, inverse: \User.tenant) var users = [User]()
    
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
}
