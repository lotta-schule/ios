//
//  ProfileView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 23/09/2023.
//

import SwiftUI

struct ProfileView : View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        VStack {
            Button("Abmelden") {
                modelData.resetUser()
            }
        }
    }
}
