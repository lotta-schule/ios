//
//  MessageBubbleFileRow.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 31/10/2023.
//

import SwiftUI
import LottaCoreAPI

struct MessageBubbleFileRow: View {
    @Environment(UserSession.self) private var userSession
    
    var file: GetConversationQuery.Data.Conversation.Message.File
    
    var body: some View {
        Button {
            guard let fileUrl = getFileUrl(file: file) else {
                return
            }
            
            guard let vc = UIApplication.shared.connectedScenes.compactMap({$0 as? UIWindowScene}).first?.windows.first?.rootViewController else {
                return
            }
            
            let shareActivity = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
            shareActivity.popoverPresentationController?.sourceView = vc.view
            shareActivity.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 0, height: 0)
            shareActivity.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            vc.present(shareActivity, animated: true, completion: nil)
        } label: {
            HStack {
                if file.fileType == FileType.image {
                    AsyncImage(
                        url: getPreviewFileUrl(file: file),
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
