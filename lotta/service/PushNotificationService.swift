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
    
    private var api: CoreApi?
    
    private var currentDeviceId: String?
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) async -> Void {
        if let api = api {
            if currentDeviceId == nil {
                do {
                    let graphqlResult = try await api.apollo.performAsync(
                        mutation: RegisterDeviceMutation(
                            device: RegisterDeviceInput(
                                deviceType: GraphQLNullable(stringLiteral: DeviceIdentificationService.shared.deviceType),
                                modelName: GraphQLNullable(stringLiteral: DeviceIdentificationService.shared.modelName),
                                operatingSystem: GraphQLNullable(stringLiteral: DeviceIdentificationService.shared.operatingSystem),
                                platformId: "ios/\(DeviceIdentificationService.shared.uniquePlatformIdentifier ?? "0")",
                                pushToken: GraphQLNullable(stringLiteral: "apns/\(deviceToken.hexEncodedString)")
                            )
                        )
                    )
                    self.currentDeviceId = graphqlResult.data?.device?.id
                    print(graphqlResult)
                } catch {
                    print("Upsala ... \(error.localizedDescription)")
                }
            }
        }
    }
    
    func startReceivingNotifications(api: CoreApi) -> Void {
        self.api = api
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
