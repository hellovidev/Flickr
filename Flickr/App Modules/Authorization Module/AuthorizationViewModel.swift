//
//  AuthorizationViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

class AuthorizationViewModel {
    
    private let authorization: AuthorizationService
    private let coordinator: CoordinatorService
    
    init(coordinator: CoordinatorService, authorization: AuthorizationService) {
        self.coordinator = coordinator
        self.authorization = authorization
    }
    
    func signin(presenter: UIViewController) {
        authorization.login(presenter: presenter) { [weak self] result in
            switch result {
            case .success:
                self?.coordinator.redirectToInitialViewController()
            case .failure(let error):
                presenter.showAlert(title: "Authorize error", message: error.localizedDescription, button: "OK")
            }
        }
    }
    
    func signup(presenter: UIViewController) {
        authorization.signup(presenter: presenter)
    }
    
}
