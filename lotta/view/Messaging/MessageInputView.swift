//
//  MessageInput.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Sentry
import SwiftUI
import LottaCoreAPI

struct MessageInputView : View {
    @Environment(UserSession.self) private var userSession: UserSession
    
    @State private var content = ""
    
    var userId: ID?
    var groupId: ID?
    var onSent: ((SendMessageMutation.Data.Message) -> ()) = { _ in }
    
    var body: some View {
        HStack {
            TextField("Message...", text: $content, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(5)
                .submitLabel(.send)
                .frame(minHeight: CGFloat(30))
                .onSubmit {
                    Task {
                        await sendMessage()
                    }
                }
            Button(action: {
                Task {
                    await sendMessage()
                }
            }, label: {
                Image(systemName: "paperplane")
                    .foregroundStyle(.primary)
            })
        }
        .padding(.horizontal, CGFloat(userSession.theme.spacing))
    }
    
    func sendMessage() async -> Void {
        do {
            let result: SendMessageMutation.Data.Message? =
                if let userId = userId {
                    try await sendMessage(content, toUser: userId)
                } else if let groupId = groupId {
                    try await sendMessage(content, toGroup: groupId)
                } else {
                    nil
                }
            if let result = result {
                onSent(result)
                content = ""
            }
        } catch {
            SentrySDK.capture(error: error)
            print("error: \(error)")
        }
    }
    
    func sendMessage(_ content: String, toUser userId: ID) async throws -> SendMessageMutation.Data.Message {
        let graphqlResult = try await userSession.api.apollo.performAsync(
            mutation: SendMessageMutation(
                message: LottaCoreAPI.MessageInput(
                    content: GraphQLNullable(stringLiteral: content),
                    recipientGroup: nil,
                    recipientUser: GraphQLNullable(SelectUserInput(id: GraphQLNullable(stringLiteral: userId)))
                )
            )
        )
        guard let messageData = graphqlResult.data?.message else {
            throw UserSessionError.generic("Invalid Message")
        }
        handleSendMessageMutationCache(graphqlResult: graphqlResult.data!)
        return messageData
    }
    
    func sendMessage(_ content: String, toGroup groupId: ID) async throws -> SendMessageMutation.Data.Message {
        let graphqlResult = try await userSession.api.apollo.performAsync(
            mutation: SendMessageMutation(
                message: LottaCoreAPI.MessageInput(
                    content: GraphQLNullable(stringLiteral: content),
                    recipientGroup: GraphQLNullable(SelectUserGroupInput(id: GraphQLNullable(stringLiteral: groupId))),
                    recipientUser: nil
                )
            )
        )
        guard let graphqlData = graphqlResult.data, let messageData = graphqlData.message else {
            throw UserSessionError.generic("Invalid Message")
        }
        handleSendMessageMutationCache(graphqlResult: graphqlResult.data!)
        return messageData
    }
    
    func handleSendMessageMutationCache(graphqlResult: SendMessageMutation.Data) -> Void {
        if let message = graphqlResult.message, let conversation = graphqlResult.message?.conversation {
            
            userSession.api.apollo.store.withinReadWriteTransaction { transaction in
                if let conversationId = conversation.id, let messageId = message.id {
                    // add / update the conversation to the conversations list
                    let getConversationsQueryCache = try transaction.read(query: GetConversationsQuery())
                    let addConversationCacheMutation = AddConversationLocalCacheMutation()
                    
                    try transaction.update(addConversationCacheMutation) { (data: inout AddConversationLocalCacheMutation.Data) in
                        let newConversation = AddConversationLocalCacheMutation.Data.Conversation(
                            _fieldData: conversation._fieldData
                        )
                        if let i = getConversationsQueryCache.conversations?.firstIndex(where: { $0?.id == conversationId }) {
                            // conversation already is in our cache. Just update with the new message
                            data.conversations?[i]?.updatedAt = newConversation.updatedAt
                        } else {
                            // conversation is new, add it to the cache
                            data.conversations?.append(newConversation)
                            // newConversation.messages = [AddConversationLocalCacheMutation.Data.Conversation.Message(id: messageId)]
                        }
                    }
                    
                    // Now add conversation details which lists the messages
                    let getConversationQueryCache = try transaction.read(query: GetConversationQuery(id: conversationId))
                    let getConversationUpdateQuery = AddMessageToConversationLocalCacheMutation(id: conversationId)
                    
                    if getConversationQueryCache.conversation?.messages?.contains(where: { $0.id == messageId }) != true {
                        var newConversation = AddMessageToConversationLocalCacheMutation.Data.Conversation(_fieldData: graphqlResult.message?.conversation._fieldData)
                        let newMessage = AddMessageToConversationLocalCacheMutation.Data.Conversation.Message(
                            _fieldData: message._fieldData
                        )
                        newConversation.messages = [newMessage]
                        try transaction.update(getConversationUpdateQuery) { (data: inout AddMessageToConversationLocalCacheMutation.Data) in
                            // Check if there is even the conversation in the cache
                            if data.conversation == nil {
                                data.conversation = newConversation
                            }
                            // The message is not yet in the cache. Add
                            data.conversation?.messages?.append(newMessage)
                        }
                        // If the message already exists in the cache, do nothing
                    }
                    
                }
            }
        }
    }
}

