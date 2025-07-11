//
//  LottaFile.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Foundation
import LottaCoreAPI
import SwiftData

final class LottaFile: Identifiable {
    var tenant: Tenant
    
    var id: ID
    
    var fileName: String?
    
    var fileType: String?
    
    init(tenant: Tenant, id: ID, fileName: String?, fileType: String?) {
        self.id = id
        self.fileName = fileName
        self.fileType = fileType
        self.tenant = tenant
    }
    
    func getUrl(format: String = "original") -> URL? {
        self.id.getUrl(for: tenant, format: format)
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationQuery.Data.Conversation.Message.File) {
        self.init(tenant: tenant, id: graphQLResult.id, fileName: graphQLResult.filename, fileType: graphQLResult.fileType.rawValue)
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: SendMessageMutation.Data.Message.File) {
        self.init(tenant: tenant, id: graphQLResult.id, fileName: nil, fileType: nil)
    }
}

typealias LottaFileID = String

extension LottaFileID {
    func getUrl(for tenant: Tenant, format: String = "original") -> URL? {
        let urlString = "https://\(tenant.slug).lotta.schule/storage/data/f/\(self)/\(format)"
        return URL(string: urlString)
    }
}

protocol GQLFileData {
    var id: String? { get }
}
