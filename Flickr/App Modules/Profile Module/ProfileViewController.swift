//
//  ProfileViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - ProfileViewController

class ProfileViewController: UIViewController {
    
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        viewModel.logout()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
