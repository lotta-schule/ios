//
//  String+toDate.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 10/12/2023.
//

import Foundation

extension String {
    func toDate() -> Date {
       ISO8601DateFormatter().date(from: self) ?? Date.now
    }
}
