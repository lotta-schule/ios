//
//  LottaLogoView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 20/10/2023.
//

import SwiftUI

struct LottaLogoView: View {
    var body: some View {
        Image(.lottaLogo)
            .resizable()
            .scaledToFit()
            .padding(75)
    }
}

#Preview {
    LottaLogoView()
}
