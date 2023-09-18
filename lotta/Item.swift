//
//  Item.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
