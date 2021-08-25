//
//  ViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit

// MARK: - UIViewController

class SignInViewController: UIViewController {
    private var networkService: NetworkService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User athorization request
        FlickrOAuth.shared.flickrLogin(presenter: self) { [weak self] result in
            switch result {
            case .success(let accessToken):
                // Initialization 'NetworkService'
                self?.networkService = .init(withAccess: AccessTokenAPI(token: accessToken.token, secret: accessToken.secretToken))
                //self?.networkService?.testLoginRequest()
            case .failure(let error):
                switch error {
                case ErrorMessage.notFound:
                    print("Error OAuth: ")
                case ErrorMessage.error(let message):
                    print("Error OAuth: \(message)")
                default:
                    print("Error OAuth: \(error.localizedDescription)")
                }
            }
        }
    }
 
}
