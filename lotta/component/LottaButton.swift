//
//  Button.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 29/09/2023.
//

import SwiftUI

struct LottaButton: View {
    var theme: Theme = Theme.Default
    
    var text: String
    var action: () -> () = {}
    var isLoading = false
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .frame(width: 160, height: 40) // Adjust the button size as needed
            } else {
                Text(text)
                    .foregroundStyle(
                        theme.primaryColor
                    )
                    .padding(CGFloat(theme.spacing))
                    .cornerRadius(CGFloat(theme.borderRadius))
                    .frame(width: 160, height: 40) // Adjust the button size as needed
            }
        }
        .overlay(
            RoundedRectangle(
                cornerRadius: CGFloat(theme.borderRadius)
            )
            .stroke(theme.primaryColor, lineWidth: 1)
        )
        .background(theme.boxBackgroundColor)
        .padding(.top, 20)
    }
    
    init(_ text: String, action: @escaping () -> Void = {}, isLoading: Bool = false) {
        self.text = text
        self.action = action
        self.isLoading = isLoading
    }
}

#Preview {
    LottaButton("Login")
        .environment(ModelData())
}

#Preview("Loading") {
    LottaButton("Login", isLoading: true)
        .environment(ModelData())
}
