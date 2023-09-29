//
//  Button.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 29/09/2023.
//

import SwiftUI

struct LottaButton: View {
    @Environment(ModelData.self) private var modelData
    
    var action: () -> () = {}
    
    var body: some View {
        Button(action: action) {
            Text("Login")
                .foregroundStyle(
                    modelData.theme.primaryColor
                )
                .padding(CGFloat(modelData.theme.spacing))
                .cornerRadius(CGFloat(modelData.theme.borderRadius))
                .frame(width: 160, height: 40) // Adjust the button size as needed
                .overlay(
                    RoundedRectangle(
                        cornerRadius: CGFloat(modelData.theme.borderRadius)
                    )
                    .stroke(modelData.theme.primaryColor, lineWidth: 1)
                )
                .background(modelData.theme.boxBackgroundColor)
                .padding(.top, 20)
        }
    }
}

#Preview {
    LottaButton()
        .environment(ModelData())
}
