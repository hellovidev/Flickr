//
//  ProfileViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - ProfileViewController

class ProfileViewController: UIViewController {
    
    private lazy var authorizationService: AuthorizationService = .init(storageService: UserDefaultsStorageService())
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        authorizationService.logout()
        
        guard let window = UIApplication.shared.windows.first else { return }
        
        let coordinator = CoordinatorService(storageService: UserDefaultsStorageService())
        coordinator.redirectToInitialViewController()
//        let authorizationStateProvider = AuthorizationStateProvider(storageService: UserDefaultsStorageService())
//        let viewController = authorizationStateProvider.getInitialViewController()
//
//        let coordinator = CoordinatorService()
//        coordinator.makeKeyAndVisible(viewController, window: window)
        
        UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: {}, completion: nil)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
