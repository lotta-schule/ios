//
//  ContentView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import Apollo
import SwiftUI
import SwiftData
import LottaCoreAPI

struct MessagingView: View {
    @Environment(UserSession.self) var userSession: UserSession
    @Environment(RouterData.self) var routerData: RouterData
    
    @State private var cancelConversationsWatcher: Cancellable?
    @State private var conversations = [GetConversationsQuery.Data.Conversation]()
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
                            try await userSession.loadConversations(force: true)
                        } catch {
                            lastErrorMessage = error.localizedDescription
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            ZStack {
                                UserAvatar(user: userSession.user)
                                OnlineBullet(session: userSession)
                                    .frame(width: 11, height: 11)
                                    .offset(x: 16.5, y: 16.5)
                            }
                            .padding(.vertical)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { showNewMessageDialog.toggle() }) {
                                Label("Neue Nachricht schreiben", systemImage: "plus")
                            }
                            .popover(isPresented: $showNewMessageDialog, content: {
                                CreateConversationView() {
                                    onCreateNewMessage($0)
                                }
                            })
                        }
                    }
                    .navigationTitle("Nachrichten")
            },
            detail: {
                if let conversationId = routerData.selectedConversationId, !conversationId.isEmpty {
                    ConversationView(conversationId: conversationId)
                } else if let newMessageDestination = newMessageDestination {
                    NewConversationView(destination: newMessageDestination)
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
        .onAppear {
            Task {
                try? await userSession.loadConversations()
            }
            watchConversations()
        }
        .onDisappear {
            mayUnwatchConversations()
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
    
    func getOnlineBullet() -> String {
        if (self.userSession.api.isWSConnected()) {
            return "🟢"
        }
        return "🔴"
    }
    
    func onCreateNewMessage(_ destination: NewMessageDestination) -> Void {
        showNewMessageDialog = false
        switch destination {
        case .group(let group):
            userSession.api.apollo.store.withinReadTransaction { transaction in
                let result = try? transaction.read(query: GetConversationsQuery())
                let conversation =
                    result?.conversations?.first(where: { conversation in
                        conversation?.groups?.contains { $0.id == group.id } ?? false
                    })
                if let conversation = conversation {
                    routerData.selectedConversationId = conversation?.id
                } else {
                    newMessageDestination = destination
                }
            }
        case .user(let user):
            userSession.api.apollo.store.withinReadTransaction { transaction in
                let result = try? transaction.read(query: GetConversationsQuery())
                let conversation =
                    result?.conversations?.first(where: { conversation in
                        conversation?.users?.contains { $0.id == user.id } ?? false
                    })
                if let conversation = conversation {
                    routerData.selectedConversationId = conversation?.id
                } else {
                    newMessageDestination = destination
                }
            }
        }
    }
    
    func watchConversations() -> Void {
        cancelConversationsWatcher?.cancel()
        cancelConversationsWatcher = userSession.api.apollo.watch(
            query: GetConversationsQuery(),
            resultHandler: { result in
                switch result {
                case .success(let graphqlResult):
                    if let conversations = graphqlResult.data?.conversations {
                        self.conversations = conversations.compactMap { $0 }
                    }
                case .failure(let error):
                    self.lastErrorMessage = String(describing: error)
                }
            })
    }
    
    func mayUnwatchConversations() -> Void {
        cancelConversationsWatcher?.cancel()
        cancelConversationsWatcher = nil
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
