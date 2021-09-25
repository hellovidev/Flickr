//
//  AuthorizationViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit

// MARK: - AuthorizationViewController

class AuthorizationViewController: UIViewController {
    
    var viewModel: AuthorizationViewModel!

    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSignInButton()
        setupSignUpButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signinAction(_ sender: UIButton) {
        viewModel.signin(presenter: self)
    }
    
    @IBAction func signupAction(_ sender: UITapGestureRecognizer) {
        viewModel.signup(presenter: self)
    }
    
    private func setupSignInButton() {
        let signinButtonTextAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        
        let signinButtonText = NSMutableAttributedString(string: "Log in with ", attributes: nil)
        let additionalText = NSAttributedString(string: "flickr.com", attributes: signinButtonTextAttributes)
        signinButtonText.append(additionalText)
        signinButton.setAttributedTitle(signinButtonText, for: .normal)
        signinButton.layer.cornerRadius = 5
    }
    
    private func setupSignUpButton() {
        let signupButtonTextAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]
        
        signupLabel.attributedText = NSAttributedString(string: "Sign up.", attributes: signupButtonTextAttributes)
        
        let signupAction = UITapGestureRecognizer(target: self, action: #selector(signupAction))
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(signupAction)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
