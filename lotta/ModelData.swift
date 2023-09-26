//
//  ModelData.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 19/09/2023.
//

import LottaCoreAPI
import Apollo
import Combine

final class ModelData: ObservableObject {
    @Published var currentTenant: Tenant
    @Published var currentUser: User
    @Published var api: CoreApi
    
    init(tenant: Tenant, session: LoginSession = LoginSession()) {
        self.currentTenant = tenant
        
        self.currentUser = session.user!
        self.api = CoreApi(userToken: session.token, tenant: tenant)
    }
}
