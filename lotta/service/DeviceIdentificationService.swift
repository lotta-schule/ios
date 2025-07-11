//
//  DeviceIdentificationService.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 03/10/2023.
//

import UIKit
import DeviceKit

@MainActor class DeviceIdentificationService {
    static let shared = DeviceIdentificationService()
    
    let modelName = Device.current.description
    
    let uniquePlatformIdentifier = UIDevice.current.identifierForVendor?.uuidString
    
    let operatingSystem =  "\(UIDevice.current.systemName)-\(UIDevice.current.systemVersion)"
    
    var deviceType: String {
        let device = Device.current
        if device.isPhone {
            return "phone"
        } else if device.isPad {
            return "tablet"
        } else {
            return "desktop"
        }
    }
}
