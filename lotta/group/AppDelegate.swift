//
//  AppDelegate.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 03/10/2023.
//

import ObjectiveC
import UIKit
import LottaCoreAPI

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            await PushNotificationService.shared.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotificationService.shared.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = PushNotificationService.shared
        return true
    }
}
