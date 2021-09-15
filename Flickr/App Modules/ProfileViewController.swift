//
//  ProfileViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - ProfileViewController

class ProfileViewController: UIViewController {
    
    private lazy var authorizationService: AuthorizationService = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        authorizationService.logout()
        
        guard let window = UIApplication.shared.windows.first else { return }
        let authorizationStateProvider = AuthorizationStateProvider()
        let viewController = authorizationStateProvider.checkStateAndReturnViewController()
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: {}, completion: nil)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
