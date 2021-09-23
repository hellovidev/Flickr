//
//  ProfileViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - ProfileViewController

class ProfileViewController: UIViewController {
    
    var coordinator: CoordinatorService!
    var authorizationService: AuthorizationService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        authorizationService.logout()
        coordinator.redirectToInitialViewController()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
