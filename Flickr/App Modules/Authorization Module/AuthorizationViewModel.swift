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
                presenter.showAlert(title: "Authorize Error", message: "Something went wrong. Please try again.", button: "OK")
                print("Authorization failed: \(error)")
            }
        }
    }
    
    func signup(presenter: UIViewController) {
        coordinator?.redirectBrowserRegister(presenter: presenter)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
