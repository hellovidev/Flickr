//
//  ViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit

class SignInViewController: UIViewController {
    let networkService: NetworkService = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkService.getOAuthToken()
    }

}
