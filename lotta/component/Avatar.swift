//
//  Avatar.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import CachedAsyncImage
import LottaCoreAPI
import SwiftUI

struct Avatar: View {
    var url: URL?
    var size: Int = 44
    
    var body: some View {
        if let url = url {
            CachedAsyncImage(
                url: url.appending(queryItems: [
                    .init(name: "aspectRatio", value: "1"),
                    .init(name: "resize", value: "cover"),
                    .init(name: "width", value: String(size * 2))
                ]),
                urlCache: .imageCache,
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
            .frame(width: CGFloat(size), height: CGFloat(size))
            .background(Color.white)
            .clipShape(.circle)
        } else {
            EmptyView()
        }
    }
    
}
