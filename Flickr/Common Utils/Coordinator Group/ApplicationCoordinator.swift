//
//  ApplicationCoordinator.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 02.10.2021.
//

import UIKit

class ApplicationCoordinator: NSObject, CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = .init()
    
    var navigationController: UINavigationController
        
    private let storageService: LocalStorageServiceProtocol
    
    private var authorizationService: AuthorizationService
            
    private let viewBuilder: ViewBuilder
    
    private var network: NetworkService? {
        willSet {
            guard let value = newValue else { return }
            viewBuilder.registerNewDependency(value)
        }
    }
    
    init(_ navigationController: UINavigationController, storageService: LocalStorageServiceProtocol, viewBuilder: ViewBuilder, authorizationService: AuthorizationService) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.authorizationService = authorizationService
        self.viewBuilder = viewBuilder
    }
    
    func start() {
        do {
            let isAutherized = try storageService.get(for: Bool.self, with: UserDefaults.Keys.isAuthorized.rawValue)
            print(isAutherized)
            let accessTokenAPI = try storageService.get(for: AccessTokenAPI.self, with: UserDefaults.Keys.tokenAPI.rawValue)
            print(accessTokenAPI)
            
            let nsida = try storageService.get(for: String.self, with: UserDefaults.Keys.nsid.rawValue)
            print(nsida)
            
            self.network = NetworkService(token: accessTokenAPI, publicKey: FlickrConstant.Key.consumerKey.rawValue, secretKey: FlickrConstant.Key.consumerSecretKey.rawValue)
            

            
            isAutherized ? redirectGeneral() : redirectAuthorization()
        } catch {
            redirectAuthorization()
        }
    }
    
    func childDidFinish(_ child: CoordinatorProtocol?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

extension ApplicationCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        /// Read the view controller we’re moving from.
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        // Check whether our view controller array already contains that view controller.
        // If it does it means we’re pushing a different view controller on top rather than popping it, so exit.
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        
        // We’re still here – it means we’re popping the view controller, so we can check whether it’s a view controller
        if let authorizationViewController = fromViewController as? AuthorizationViewController {
            // We're popping a view controller; end its coordinator
            childDidFinish(authorizationViewController.viewModel.coordinator)
        }
        
//        if let registerViewController = fromViewController as? RegisterViewController {
//            // We're popping a view controller; end its coordinator
//            childDidFinish(registerViewController.viewModel?.coordinator)
//        }
    }
    
}

// MARK: - Delegate Authentication Coordinator

extension ApplicationCoordinator: AuthorizationCoordinatorDelegate {
    
    func coordinatorDidAuthenticate(coordinator: AuthorizationCoordinator) {
        do {
            let accessTokenAPI = try storageService.get(for: AccessTokenAPI.self, with: UserDefaults.Keys.tokenAPI.rawValue)
            
            self.network = NetworkService(token: accessTokenAPI, publicKey: FlickrConstant.Key.consumerKey.rawValue, secretKey: FlickrConstant.Key.consumerSecretKey.rawValue)
            
            redirectGeneral()
        } catch {
            print("Error")
        }
        
    }
    
}

// MARK: - GeneralCoordinatorDelegate

extension ApplicationCoordinator: GeneralCoordinatorDelegate {
    
    func coordinatorDidLogout(coordinator: GeneralCoordinator) {
        authorizationService.logout()
        redirectAuthorization()
    }
    
}

extension ApplicationCoordinator {
    
    fileprivate func redirectAuthorization() {
        let childAuthorization = AuthorizationCoordinator(navigationController, viewBuilder: viewBuilder, authorizationService: authorizationService)
        childAuthorization.parentCoordinator = self
        childAuthorization.delegate = self
        childCoordinators.append(childAuthorization)
        childAuthorization.start()
    }
    
    fileprivate func redirectGeneral() {
        let childGeneral = GeneralCoordinator(navigationController, viewBuilder: viewBuilder)
        childGeneral.parentCoordinator = self
        childGeneral.delegate = self
        childCoordinators.append(childGeneral)
        childGeneral.start()
    }
    
}
