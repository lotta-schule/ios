//
//  NewMessageDestination.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/11/2023.
//

import Foundation
import LottaCoreAPI

enum NewMessageDestination {
    case user(SearchUsersQuery.Data.User)
    case group(Group)
}

extension NewMessageDestination : Equatable {}
