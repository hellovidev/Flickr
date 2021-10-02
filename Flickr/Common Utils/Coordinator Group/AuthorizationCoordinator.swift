//
//  AuthorizationCoordinator.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 02.10.2021.
//

import UIKit

protocol AuthorizationCoordinatorDelegate: AnyObject {
    func coordinatorDidAuthenticate(coordinator: AuthorizationCoordinator)
}

class AuthorizationCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = .init()
    
    var navigationController: UINavigationController
    
    weak var parentCoordinator: ApplicationCoordinator?
    
    weak var delegate: AuthorizationCoordinatorDelegate?
    
    private let authorizationService: AuthorizationService

    init(_ navigationController: UINavigationController, authorizationService: AuthorizationService) {
        self.navigationController = navigationController
        self.authorizationService = authorizationService
    }
    
    func start() {
        let authorizationViewController: AuthorizationViewController = Storyboard.main.instantiateViewController()
        authorizationViewController.viewModel = .init(coordinator: self)
        navigationController.setViewControllers([authorizationViewController], animated: true)
    }
    
    func redirectBrowserRegister(presenter: UIViewController) {
        let signupWebView: WKWebViewController = .init(endpoint: FlickrConstant.URL.signup.rawValue)
        signupWebView.delegate = self
        presenter.present(signupWebView, animated: true, completion: nil)
    }
    
    func redirectBrowserLogin(presenter: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        authorizationService.login(presenter: presenter, completion: completion)
    }
        
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

// MARK: - didAuthenticate called by LoginViewModel

extension AuthorizationCoordinator {

    func didAuthenticate() {
        parentCoordinator?.childDidFinish(self)
        parentCoordinator?.coordinatorDidAuthenticate(coordinator: self)
    }
    
}


// MARK: - WKWebViewDelegate

extension AuthorizationCoordinator: WKWebViewControllerDelegate {
    
    func close(viewController: WKWebViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
