//
//  Avatar.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import LottaCoreAPI
import SwiftUI
import NukeUI

struct Avatar: View {
    var url: URL?
    var size: Int = 44
    
    var body: some View {
        if let url = url {
            LazyImage(
                url: url,
                transaction: Transaction(animation: .easeIn)
            ) { state in
                if let image = state.image {
                    image.resizable().scaledToFill()
                } else if let _error = state.error {
                    Image(systemName: "wifi.slash")
                } else {
                    EmptyView()
                }
            }
            .frame(width: CGFloat(size), height: CGFloat(size))
            .background(Color.white)
            .clipShape(.circle)
        } else {
            EmptyView()
        }
    }
    
}
