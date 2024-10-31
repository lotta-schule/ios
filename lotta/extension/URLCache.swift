//
//  URLCache.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 31/10/2024.
//

import Foundation

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 128_000_000, diskCapacity: 256_000_000)
}
