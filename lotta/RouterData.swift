//
//  RouterData.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 29/10/2023.
//

import Foundation
import LottaCoreAPI

@MainActor @Observable final class RouterData {
    static let shared = RouterData()
    
    var rootSection: RootSection = .messaging
    
    var selectedConversationId: ID? = nil
    
    func reset() -> Void {
        rootSection = .messaging
        selectedConversationId = nil
    }
    
    enum RootSection {
        case messaging
        case profile
    }
}
