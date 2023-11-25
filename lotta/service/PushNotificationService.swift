//
//  PushNotificationService.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 03/10/2023.
//

import UIKit
import Sentry
import LottaCoreAPI
import UserNotifications

class PushNotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PushNotificationService()
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) async -> Void {
        for session in ModelData.shared.userSessions {
            do {
                try await session.registerDevice(token: deviceToken)
            } catch {
                print("Upsala ... \(error.localizedDescription)")
            }
        }
    }
    
    func startReceivingNotifications(api: CoreApi) -> Void {
        let receiveMessageCategory = UNNotificationCategory(identifier: "receive_message", actions: [], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([receiveMessageCategory])
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission()
            case .authorized, .provisional:
                // Let's see ...
                print("OK you are allowed to bother me.")
            default:
                break
            }
        }
    }
    
    private func requestPermission() -> Void {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
                SentrySDK.capture(error: error)
            } else {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                didReceive response: UNNotificationResponse,
                withCompletionHandler completionHandler:
                   @escaping () -> Void) {
       print(response)
        switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
            let threadIdentifier = response.notification.request.content.threadIdentifier.split(separator: "/")
            if let tenantSlug = threadIdentifier.first, let conversationId = threadIdentifier.last {
                if ModelData.shared.setSession(byTenantSlug: String(tenantSlug)) {
                    RouterData.shared.selectedConversationId = String(conversationId)
                }
            }
            default:
                print("Unknown action \(response.actionIdentifier)")
        }
       
       completionHandler()
    }
}
