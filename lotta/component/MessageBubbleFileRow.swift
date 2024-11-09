//
//  MessageBubbleFileRow.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 31/10/2023.
//

import SwiftUI
import QuickLook
import LottaCoreAPI
import NukeUI

struct MessageBubbleFileRow: View {
    @Environment(UserSession.self) private var userSession
    
    @State private var isShowingPreview = false

    var files: [GetConversationQuery.Data.Conversation.Message.File]

    var body: some View {
        if files.isEmpty {
            EmptyView()
        } else {
            Button {
                isShowingPreview = true
            } label: {
                HStack {
                    ForEach(files, id: \.id) { file in
                        VStack(alignment: .leading) {
                            if file.fileType == FileType.image {
                                LazyImage(
                                    url: getPreviewFileUrl(file: file),
                                    transaction: Transaction(animation: .easeIn)
                                ) { state in
                                    if let image = state.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } else if let _ = state.error {
                                        Image(systemName: "wifi.slash")
                                            .scaledToFit()
                                    } else if state.isLoading {
                                        ProgressView()
                                            .scaledToFit()
                                    } else {
                                        EmptyView()
                                            .scaledToFill()
                                    }
                                }
                            } else {
                                Image(systemName: "doc")
                                    .scaledToFit()
                            }
                        }
                        .frame(height: 150)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(file.id)
                    }
                }
                .background(Color.red.opacity(1))
            }
            .sheet(isPresented: $isShowingPreview) {
                FilePreview(file: files[0]) {
                    isShowingPreview = false
                }
            }
        }
    }
    
    func getFileUrl(file: GetConversationQuery.Data.Conversation.Message.File) -> URL? {
        return file.id?.getUrl(for: userSession.tenant)
    }
    
    func getPreviewFileUrl(file: GetConversationQuery.Data.Conversation.Message.File) -> URL? {
        return file.id?
            .getUrl(for: userSession.tenant, queryItems: [
                .init(name: "height", value: "150"),
                .init(name: "resize", value: "contain")
            ])
    }
}
