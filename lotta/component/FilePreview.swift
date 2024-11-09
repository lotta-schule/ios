//
//  FilePreview.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 09/11/2024.
//

import SwiftUI
import LottaCoreAPI
import WebKit

struct FilePreview: View {
    @Environment(UserSession.self) private var userSession
    @Environment(\.modelContext) private var modelContext
    
    var file: GetConversationQuery.Data.Conversation.Message.File
    var onDismiss: (() -> Void)
    
    var body: some View {
        NavigationView {
            VStack {
                WebView(url: getFileUrl(file: file) ?? URL(string: "data:base64,NotFound")!)
                Button("OK") {
                    onDismiss()
                }
            }
            .navigationTitle(file.filename ?? "")
        }
    }
    
    func getFileUrl(file: GetConversationQuery.Data.Conversation.Message.File) -> URL? {
        return file.id?.getUrl(for: userSession.tenant)
    }
}
