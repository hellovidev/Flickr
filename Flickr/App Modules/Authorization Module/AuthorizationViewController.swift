//
//  AuthorizationViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit

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
                guard let window = UIApplication.shared.windows.first else { return }
                
                let coordinator = CoordinatorService(storageService: UserDefaultsStorageService())
                coordinator.redirectToInitialViewController()
                
//                let authorizationStateProvider = AuthorizationStateProvider(storageService: UserDefaultsStorageService())
//                let viewController = authorizationStateProvider.getInitialViewController()
//                
//                let coordinator = CoordinatorService()
//                coordinator.makeKeyAndVisible(viewController, window: window)
//                
                UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: {}, completion: nil)
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
