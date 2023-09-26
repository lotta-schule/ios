//
//  LottaFile.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Foundation
import LottaCoreAPI
import SwiftData

@Model
final class LottaFile: Identifiable {
    @Attribute(.unique) var id: ID
    
    var tenant: Tenant
    
    init(tenant: Tenant, id: ID) {
        self.tenant = tenant
        self.id = id
    }
    
    func getUrl(queryItems: [URLQueryItem] = []) -> URL? {
        self.id.getUrl(queryItems: queryItems)
    }
}

typealias LottaFileID = String

extension LottaFileID {
    func getUrl(queryItems: [URLQueryItem] = []) -> URL? {
        let urlString = "https://ehrenberg.staging.lotta.schule/storage/f/\(self)"
        return URL(string: urlString)?
            .appending(queryItems: queryItems)
    }
}
