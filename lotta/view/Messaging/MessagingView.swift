//
//  ContentView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import SwiftUI
import SwiftData
import LottaCoreAPI

struct MessagingView: View {
    @Environment(UserSession.self) var userSession: UserSession
    @Environment(RouterData.self) var routerData: RouterData
    @State private var showNewMessageDialog = false
    @State private var newMessageDestination: NewMessageDestination? = nil
    @State private var isAlertViewPresented = false
    @State private var lastErrorMessage: String?
    
    var body: some View {
        NavigationSplitView(
            sidebar: {
                ConversationsList(withNewMessageDestination: newMessageDestination)
                    .refreshable {
                        do {
                            try await userSession.forceLoadConversations()
                        } catch {
                            lastErrorMessage = error.localizedDescription
                        }
                    }
                    .toolbar {
                        ToolbarItem {
                            Button(action: { showNewMessageDialog.toggle() }) {
                                Label("Neue Nachricht schreiben", systemImage: "plus")
                            }
                            .popover(isPresented: $showNewMessageDialog, content: {
                                CreateConversationView(
                                    onSelect: { destination in
                                        showNewMessageDialog = false
                                        switch destination {
                                            case .group(let group):
                                                if let conversation = userSession.conversations.first(where: { conversation in
                                                    conversation.groups.contains(where: { $0.id == group.id })
                                                }) {
                                                    routerData.selectedConversationId = conversation.id
                                                } else {
                                                    newMessageDestination = destination
                                                }
                                            case .user(let user):
                                                if let conversation = userSession.conversations.first(where: { conversation in
                                                    conversation.users.contains(where: { $0.id == user.id })
                                                }) {
                                                    routerData.selectedConversationId = conversation.id
                                                } else {
                                                    newMessageDestination = destination
                                                }
                                        }
                                    }
                                )
                            })
                        }
                }
            },
            detail: {
                if let conversationId = routerData.selectedConversationId, !conversationId.isEmpty {
                    ConversationView(conversationId: conversationId)
                } else if let newMessageDestination = newMessageDestination {
                    NewConversationView(destination: newMessageDestination)
                } else {
                    Text("Unterhaltung wählen")
                }
            }
        )
        .alert(
            isPresented: $isAlertViewPresented
        ) {
            Alert(
                title: Text("Fehler"),
                message: Text(lastErrorMessage ?? "Unbekannter Fehler")
            )
        }
        .onChange(of: routerData.selectedConversationId, { _, _ in
            if routerData.selectedConversationId?.isEmpty != true {
                newMessageDestination = nil
            }
        })
        .onChange(of: newMessageDestination, { _, _ in
            if newMessageDestination != nil {
                routerData.selectedConversationId = ""
            }
        })
        .onChange(of: lastErrorMessage) { _, _ in
            if (lastErrorMessage != nil) {
                isAlertViewPresented = true
            }
        }
        .onChange(of: isAlertViewPresented) { _, _ in
            if !isAlertViewPresented {
                lastErrorMessage = nil
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            // let newItem = Item(timestamp: Date())
            // modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            // for index in offsets {
                // modelContext.delete(items[index])
            // }
        }
    }
}

#Preview {
    MessagingView()
        .environment(
            UserSession(
                tenant: Tenant(
                    id: "0",
                    title: "",
                    slug: "slug"),
                authInfo: AuthInfo(),
                user: User(tenant: Tenant(
                    id: "0",
                    title: "",
                    slug: "slug"), id: "0")
            )
        )
        .environment(RouterData())
}
