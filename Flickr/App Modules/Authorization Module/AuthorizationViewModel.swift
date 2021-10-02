//
//  AuthorizationViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

class AuthorizationViewModel {
    
    weak var coordinator: AuthorizationCoordinator?
    
    init(coordinator: AuthorizationCoordinator) {
        self.coordinator = coordinator
    }
    
    func signin(presenter: UIViewController) {
        coordinator?.redirectBrowserLogin(presenter: presenter) { [weak self] result in
            switch result {
            case .success:
                self?.coordinator?.didAuthenticate()
            case .failure(let error):
                presenter.showAlert(title: "Authorize error", message: error.localizedDescription, button: "OK")
            }
        }
    }
    
    func signup(presenter: UIViewController) {
        coordinator?.redirectBrowserRegister(presenter: presenter)
    }
    
}

