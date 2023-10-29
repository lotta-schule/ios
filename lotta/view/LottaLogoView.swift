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
            .scaledToFit()
            .frame(width: 100, height: 100, alignment: .center)
    }
}

#Preview {
    LottaLogoView()
}
