//
//  UserAvatar.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 21/09/2023.
//
import LottaCoreAPI
import SwiftUI

struct UserAvatar: View {
    var user: User
    
    var body: some View {
        Avatar(url: URL(string: user.avatarImageFile!))
    }
}
