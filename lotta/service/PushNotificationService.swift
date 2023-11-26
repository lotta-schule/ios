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
    
    func startReceivingNotifications() -> Void {
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
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        switch UIApplication.shared.applicationState {
        case .active:
            if let tenantId = userInfo["tenant_id"] as? Int,
               let session = ModelData.shared.userSessions.first(where: { $0.tenant.id == tenantId.formatted(.number) }) {
                Task {
                    do {
                        try await session.forceLoadConversations()
                        completionHandler(.newData)
                    } catch {
                        print("Error refetching conversations: \(error)")
                        completionHandler(.failed)
                    }
                }
            }
            
        case .background:
            if let tenantId = userInfo["tenant_id"] as? Int,
               let session = ModelData.shared.userSessions.first(where: { $0.tenant.id == tenantId.formatted(.number) }),
               let conversationId = userInfo["conversation_id"] as? String {
                session.api.apollo.fetch(query: GetConversationQuery(id: conversationId, markAsRead: false), cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                    case .success(let graphqlResult):
                        if let conversationData = graphqlResult.data?.conversation {
                            session.api.apollo.store.withinReadWriteTransaction { transaction in
                                // add / update the conversation to the conversations list
                                let getConversationsQueryCache = try transaction.read(query: GetConversationsQuery())
                                let addConversationCacheMutation = AddConversationLocalCacheMutation()
                                
                                try transaction.update(addConversationCacheMutation) { (data: inout AddConversationLocalCacheMutation.Data) in
                                    let newConversation = AddConversationLocalCacheMutation.Data.Conversation(
                                        _fieldData: conversationData._fieldData
                                    )
                                    if let i = getConversationsQueryCache.conversations?.firstIndex(where: { $0?.id == conversationId }) {
                                        // conversation already is in our cache. Just update with the new message
                                        data.conversations?[i]?.updatedAt = newConversation.updatedAt
                                        data.conversations?[i]?.unreadMessages = newConversation.unreadMessages
                                    } else {
                                        // conversation is new, add it to the cache
                                        data.conversations?.append(newConversation)
                                        // newConversation.messages = [AddConversationLocalCacheMutation.Data.Conversation.Message(id: messageId)]
                                    }
                                }
                                Task {
                                    await ModelData.shared.setApplicationBadgeNumber()
                                    completionHandler(.newData)
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                        completionHandler(.failed)
                    }
                }
            }
        default:
            print("notification: \(userInfo)")
            completionHandler(.noData)
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
