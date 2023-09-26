//
//  ProfileView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 23/09/2023.
//

import SwiftUI

struct ProfileView : View {
    var onLogout: () -> ()
    
    var body: some View {
        VStack {
            Button("Abmelden") {
                onLogout()
            }
        }
    }
}
