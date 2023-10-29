//
//  PushNotificationService.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 03/10/2023.
//

import UserNotifications
import UIKit
import LottaCoreAPI

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
    
    func stopReceivingNotifications() async -> Void {
        if let api = api, let currentDeviceId = currentDeviceId  {
            do {
                let graphqlResult = try await api.apollo.performAsync(
                    mutation: UpdateDeviceMutation(
                        id: currentDeviceId,
                        device: UpdateDeviceInput(
                            pushToken: nil
                        )
                    )
                )
            } catch {
                print("Upsala Lala! Error: \(error)")
            }
            self.api = nil
        }
    }
    
    private func requestPermission() -> Void {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
