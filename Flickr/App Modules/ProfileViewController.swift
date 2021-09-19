//
//  ProfileViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - ProfileViewController

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        AuthorizationService.shared.logout()
                
        let coordinator = CoordinatorService(storageService: UserDefaultsStorageService())
        coordinator.redirectToInitialViewController()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
