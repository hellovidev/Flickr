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
    
    private let authorizationService: AuthorizationService
    
    private var networkService: NetworkService?
    
    private var nsid: String?
    
    init(_ navigationController: UINavigationController, storageService: LocalStorageServiceProtocol, authorizationService: AuthorizationService) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.authorizationService = authorizationService
    }
    
    func start() {
        do {
            let isAutherized = try storageService.get(for: Bool.self, with: UserDefaultsKey.isAuthorized.rawValue)
            let accessTokenAPI = try storageService.get(for: AccessTokenAPI.self, with: UserDefaultsKey.tokenAPI.rawValue)
            
            self.networkService = NetworkService(token: accessTokenAPI, publicKey: FlickrConstant.Key.consumerKey.rawValue, secretKey: FlickrConstant.Key.consumerSecretKey.rawValue)
            
            guard let nsid = accessTokenAPI.nsid.removingPercentEncoding else {
                fatalError("Invalid NSID")
            }
            
            self.nsid = nsid
            
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
            let accessTokenAPI = try storageService.get(for: AccessTokenAPI.self, with: UserDefaultsKey.tokenAPI.rawValue)
            
            self.networkService = NetworkService(token: accessTokenAPI, publicKey: FlickrConstant.Key.consumerKey.rawValue, secretKey: FlickrConstant.Key.consumerSecretKey.rawValue)
            
            guard let nsid = accessTokenAPI.nsid.removingPercentEncoding else {
                fatalError("Invalid NSID")
            }
            
            self.nsid = nsid
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
        let childAuthorization = AuthorizationCoordinator(navigationController, authorizationService: authorizationService)
        childAuthorization.parentCoordinator = self
        childAuthorization.delegate = self
        childCoordinators.append(childAuthorization)
        childAuthorization.start()
    }
    
    fileprivate func redirectGeneral() {
        let childGeneral = GeneralCoordinator(navigationController, networkService: networkService!, nsid: nsid!)
        childGeneral.parentCoordinator = self
        childGeneral.delegate = self
        childCoordinators.append(childGeneral)
        childGeneral.start()
    }
    
}
