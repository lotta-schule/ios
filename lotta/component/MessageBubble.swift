//
//  MessageBubble.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI

struct MessageBubble : View {
    @Environment(ModelData.self) private var modelData: ModelData
    var message: Message
    var fromCurrentUser: Bool
    
    var body: some View {
        Text(message.content ?? "[File-Message]")
            .padding(10)
            .foregroundColor(fromCurrentUser ? modelData.currentTenant?.getThemeColor(forKey: "contrastTextColor") : modelData.currentTenant?.getThemeColor(forKey: "textColor"))
            .background(fromCurrentUser ? modelData.currentTenant?.getThemeColor(forKey: "primaryColor")  : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
            .cornerRadius(10)
    }
}
