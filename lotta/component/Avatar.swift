//
//  Avatar.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import LottaCoreAPI
import SwiftUI

struct Avatar: View {
    var url: URL?
    
    var body: some View {
        if let url = url {
            AsyncImage(
                url: url.appending(queryItems: [.init(name: "aspectRatio", value: "1"), .init(name: "resize", value: "cover")]),
                transaction: Transaction(animation: .easeInOut)
            ) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "wifi.slash")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 44, height: 44)
            .background(Color.white)
            .clipShape(.circle)
        } else {
            EmptyView()
        }
    }
    
}
