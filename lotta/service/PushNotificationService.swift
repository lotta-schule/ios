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
            print("deviceToken: \(deviceToken.hexEncodedString)")
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
            case .notDetermined, .authorized, .provisional:
                self.requestPermission()
            default:
                print("Not asking for permission because authorizationStatus is: \(settings.authorizationStatus)")
                break
            }
        }
    }
    
    func removeNotificationsFor(conversationId: String) async -> Void {
        let notifications = await UNUserNotificationCenter.current().deliveredNotifications()
        let notificationsToDelete = notifications.filter { notification in
            notification.request.content.threadIdentifier.hasSuffix("/\(conversationId)")
        }
        if !notificationsToDelete.isEmpty {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: notificationsToDelete.map(\.request.identifier))
        }
    }
    
    @MainActor
    func didReceiveRemoteNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let crumb = Breadcrumb(level: .info, category: "PushNotification")
        crumb.message = "Received push notification: \(userInfo)"
        SentrySDK.addBreadcrumb(crumb)
        guard let tenantId = userInfo["tenant_id"] as? Int else {
            SentrySDK.capture(message: "Received push notification without tenant_id")
            completionHandler(.failed)
            return
        }
        Task {
            if !ModelData.shared.initialized {
                await ModelData.shared.initializeSessions()
            }
            switch UIApplication.shared.applicationState {
            case .active:
                let crumb = Breadcrumb(level: .info, category: "PushNotification")
                crumb.message = "Application is active"
                SentrySDK.addBreadcrumb(crumb)
                guard let session = ModelData.shared.userSessions.first(where: { $0.tenant.id == tenantId.formatted(.number) }) else {
                    SentrySDK.capture(message: "Received push notification for unknown tenant \(tenantId)")
                    completionHandler(.failed)
                    return
                }
                do {
                    try await session.loadConversations(force: true)
                    completionHandler(.newData)
                } catch {
                    SentrySDK.capture(error: error)
                    completionHandler(.failed)
                }
                
            case .background:
                let crumb = Breadcrumb(level: .info, category: "PushNotification")
                crumb.message = "Application is in background"
                SentrySDK.addBreadcrumb(crumb)
                guard let conversationId = userInfo["conversation_id"] as? String else {
                    SentrySDK.capture(message: "Received push notification for unknown conversation \(tenantId)")
                    completionHandler(.failed)
                    return
                }
                guard let session = ModelData.shared.userSessions.first(where: { $0.tenant.id == tenantId.formatted(.number) }) else {
                    SentrySDK.capture(message: "Received push notification for unknown tenant \(tenantId)")
                    completionHandler(.failed)
                    return
                }
                
                // if this was a "read_conversation" type of message, remove the delivered notifications of this conversation from the notification center
                if let aps = userInfo["aps"] as? [String: Any], let category = aps["category"] as? String, category == "read_conversation" {
                    await removeNotificationsFor(conversationId: conversationId)
                }

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
                        SentrySDK.capture(error: error)
                        print(error)
                        completionHandler(.failed)
                    }
                }
            default:
                print("notification: \(userInfo)")
                completionHandler(.noData)
            }
        }
    }
    
    private func requestPermission() -> Void {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                SentrySDK.capture(error: error)
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let crumb = Breadcrumb(level: .info, category: "PushNotication")
        crumb.message = "Received push notification"
        crumb.data = response.notification.request.content.userInfo as? [String: Any]
        if !ModelData.shared.initialized {
            await ModelData.shared.initializeSessions()
        }
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
    }
    
}
