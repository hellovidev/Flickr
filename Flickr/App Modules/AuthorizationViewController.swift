//
//  AuthorizationViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit
import WebKit

// MARK: - AuthorizationViewController

class AuthorizationViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupLabel: UILabel!
    
    var authorizationService: AuthorizationService!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let loginButtonTextAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        
        let loginButtonText = NSMutableAttributedString(string: "Log in with ", attributes: nil)
        let flickrLinkText = NSAttributedString(string: "flickr.com", attributes: loginButtonTextAttributes)
        loginButtonText.append(flickrLinkText)
        loginButton.setAttributedTitle(loginButtonText, for: .normal)
        loginButton.layer.cornerRadius = 5
        
        let signupLabelTextAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]

        signupLabel.sizeToFit()
        signupLabel.attributedText = NSAttributedString(string: "Sign up.", attributes: signupLabelTextAttributes)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let signupAction = UITapGestureRecognizer(target: self, action: #selector(signupAction(sender:)))
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(signupAction)
    }

    @IBAction func loginAction(_ sender: UIButton) {
        authorizationService.login(presenter: self) { [weak self] result in
            switch result {
            case .success:
                self?.performSegue(withIdentifier: "HomePath", sender: self)
            case .failure(let error):
                self?.showAlert(title: "Authorize error", message: error.localizedDescription, button: "OK")
            }
        }
    }
    
    @IBAction func signupAction(sender: UITapGestureRecognizer) {
        authorizationService.signup(presenter: self)
    }
        
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
