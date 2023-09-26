//
//  MessageInput.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import LottaCoreAPI
import SwiftUI

struct MessageInput : View {
    @EnvironmentObject var modelData: ModelData
    var user: User?
    var group: Group?
    var onSent: (Message) -> ()
    
    @State var content = ""
    
    var body: some View {
        HStack {
           TextField("Message...", text: $content)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    .foregroundStyle(.black)
            })
        }
        .padding(4)
    }
    
    func sendMessage() async -> Void {
        do {
            var recipientGroup: GraphQLNullable<SelectUserGroupInput> = nil
            var recipientUser: GraphQLNullable<SelectUserInput> = nil
            if let group = group {
                recipientGroup = GraphQLNullable(SelectUserGroupInput(id: GraphQLNullable(stringLiteral: group.id)))
            }
            if let user = user {
                recipientUser = GraphQLNullable(SelectUserInput(id: GraphQLNullable(stringLiteral: user.id)))
            }
            let graphqlResult = try await modelData.api.apollo.performAsync(
                mutation: SendMessageMutation(
                    message: LottaCoreAPI.MessageInput(
                        content: GraphQLNullable(stringLiteral: content),
                        recipientGroup: recipientGroup,
                        recipientUser: recipientUser
                    )
                )
            )
            if let message = graphqlResult.data?.message {
                onSent(Message(from: message, for: modelData.api.tenant!))
                content = ""
            }
            print(graphqlResult)
        } catch {
            print("error: \(error)")
        }
    }
}

#Preview {
    MessageInput { message in
        print(message)
    }
}
