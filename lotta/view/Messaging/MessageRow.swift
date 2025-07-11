//
//  MessageView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct MessageRow : View {
    @Environment(UserSession.self) private var userSession
    
    var message: GetConversationQuery.Data.Conversation.Message
    var fromCurrentUser: Bool
    var isGroupChat: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: CGFloat(userSession.theme.spacing)) {
            if isGroupChat {
                if fromCurrentUser {
                    Spacer()
                } else {
                    if let imageId = message.user?.avatarImageFile?.id {
                        Avatar(
                            url:
                                imageId.getUrl(
                                    for: userSession.tenant, format: "avatar_250"
                                ),
                            size: 30
                        )
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(.leading, CGFloat(userSession.theme.borderRadius))
                    } else {
                        EmptyView()
                    }
                }
            } else if fromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: fromCurrentUser ? .trailing : .leading) {
                MessageBubble(
                    message: message,
                    fromCurrentUser: fromCurrentUser,
                    isGroupChat: isGroupChat
                )
                Text(getFormattedDateLine())
                    .font(.footnote)
                    .foregroundStyle(userSession.theme.disabledColor)
                    .padding(.trailing, CGFloat(integerLiteral: userSession.theme.spacing))
                    .padding(.top, CGFloat(integerLiteral: userSession.theme.spacing) * -0.75)
            }
            
            if (!fromCurrentUser) {
                Spacer()
            }
        }
        .scaledToFill()
    }
    
    func getFormattedDateLine() -> String {
        let username = if !isGroupChat || fromCurrentUser {
            ""
        } else if let user = message.user {
            "\(UserUtil.getVisibleName(for: user)) • "
        } else {
            ""
        }
        
        let dateString = formatDate(message.insertedAt.toDate())
        
        return [username, dateString].joined(separator: "")
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "de-DE")
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: date)
    }
}
