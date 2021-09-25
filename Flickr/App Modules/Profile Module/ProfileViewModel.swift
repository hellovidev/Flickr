//
//  ProfileViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import Foundation

class ProfileViewModel {

    private let coordinator: CoordinatorService
    private let authorization: AuthorizationService
    
    init(coordinator: CoordinatorService, authorization: AuthorizationService) {
        self.coordinator = coordinator
        self.authorization = authorization
    }
    
    func logout() {
        authorization.logout()
        coordinator.redirectToInitialViewController()
    }
    
}
