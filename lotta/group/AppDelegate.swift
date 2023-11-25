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
        switch UIApplication.shared.applicationState {
            case .active:
                print("notification: \(userInfo)")
            case .background:
            if let tenantId = userInfo["tenant_id"] as? Int,
               let session = ModelData.shared.userSessions.first(where: { $0.tenant.id == tenantId.formatted(.number) }),
               let conversationId = userInfo["conversation_id"] as? String {
                session.api.apollo.fetch(query: GetConversationQuery(id: conversationId), cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                        case .success(let graphQLResult):
                            let conversation = Conversation(in: session.tenant, from: graphQLResult.data!.conversation!)
                            session.addConversation(conversation)
                            ModelData.shared.setApplicationBadgeNumber()
                            completionHandler(.newData)
                        case .failure(let error):
                            print(error)
                            completionHandler(.failed)
                    }
                }
            }
            default:
                print("notification: \(userInfo)")
        }
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = PushNotificationService.shared
        
        return true
    }
}
