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
    
    var file: GetConversationQuery.Data.Conversation.Message.File
    var index: Int
    var dataSource: MessageQLPreviewDataSource
    
    @State var isLoading = false

    var body: some View {
        Button {
            guard let vc = UIApplication.shared.connectedScenes.compactMap({$0 as? UIWindowScene}).first?.windows.first?.rootViewController else {
                return
            }
            
            let previewController = QLPreviewController()
            previewController.currentPreviewItemIndex = index
            previewController.dataSource = dataSource
            
            isLoading = true
            dataSource.loadFiles {
                isLoading = false
                DispatchQueue.main.sync {
                    vc.present(previewController, animated: true)
                }
            }
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
            .opacity(isLoading ? 0.5 : 1.0)
        }
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
