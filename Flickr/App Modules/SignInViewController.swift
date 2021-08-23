//
//  ViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit

// MARK: - UIViewController

class SignInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User athorization request
        FlickrOAuth.shared.flickrLogin(presenter: self) { result in
            switch result {
            case .success(let accessToken):
                print(accessToken)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
 
}
