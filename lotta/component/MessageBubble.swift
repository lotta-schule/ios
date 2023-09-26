//
//  MessageBubble.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI

struct MessageBubble : View {
    var message: Message
    var fromCurrentUser: Bool
    
    var body: some View {
        Text(message.content ?? "[File-Message]")
            .padding(10)
            .foregroundColor(fromCurrentUser ? Color.white : Color.black)
            .background(fromCurrentUser ? Color.blue : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
            .cornerRadius(10)
    }
}
