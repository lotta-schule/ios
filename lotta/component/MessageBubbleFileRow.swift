//
//  MessageBubbleFileRow.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 31/10/2023.
//

import SwiftUI
import QuickLook
import LottaCoreAPI
import CachedAsyncImage

struct MessageBubbleFileRow: View {
    @Environment(UserSession.self) private var userSession
    
    @State private var isShowingPreview = false

    var file: GetConversationQuery.Data.Conversation.Message.File

    var body: some View {
        Button {
            isShowingPreview = true
        } label: {
            HStack {
                if file.fileType == FileType.image {
                    CachedAsyncImage(
                        url: getPreviewFileUrl(file: file),
                        urlCache: .imageCache,
                        transaction: Transaction(animation: .easeInOut)
                    ) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            Image(systemName: "wifi.slash")
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                if let fileName = file.filename {
                    Text(fileName)
                }
            }
        }
        .sheet(isPresented: $isShowingPreview) {
            FilePreview(file: file) {
                isShowingPreview = false
            }
        }
        .frame(minHeight: 0.3, maxHeight: 0.8)
    }
    
    func getFileUrl(file: GetConversationQuery.Data.Conversation.Message.File) -> URL? {
        return file.id?.getUrl(for: userSession.tenant)
    }
    
    func getPreviewFileUrl(file: GetConversationQuery.Data.Conversation.Message.File) -> URL? {
        return file.id?
            .getUrl(for: userSession.tenant, queryItems: [
                .init(name: "width", value: "150"),
                .init(name: "resize", value: "contain")
            ])
    }
}
