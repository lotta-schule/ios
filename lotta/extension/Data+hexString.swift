//
//  Data+hexString.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 03/10/2023.
//

import Foundation

extension Data {
    var hexEncodedString: String {
        return self.reduce(into:"") { result, byte in
            result.append(String(byte >> 4, radix: 16))
            result.append(String(byte & 0x0f, radix: 16))
        }
    }
}
