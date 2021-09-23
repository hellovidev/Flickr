//
//  Coordinator.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 16.09.2021.
//

import UIKit

struct CoordinatorService {
    
    private var window: UIWindow?
    
    private let storyboard: UIStoryboard
    private let storageService: LocalStorageServiceProtocol
    private let authorizationService: AuthorizationService
    
    init(storageService: LocalStorageServiceProtocol, authorizationService: AuthorizationService) {
        self.storageService = storageService
        self.window = UIApplication.shared.windows.first
        self.storyboard = UIStoryboard(name: Storyboard.main.rawValue, bundle: Bundle.main)
        self.authorizationService = authorizationService
    }
    
    func redirectToInitialViewController() {
        let viewController = getInitialViewController()
        makeKeyAndVisible(viewController)
        
        if let window = self.window {
            UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: {}, completion: nil)
        }
    }
    
    private func makeKeyAndVisible(_ viewController: UIViewController) {
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
    
    private func getInitialViewController() -> UIViewController {
        do {
            let isAutherized = try storageService.get(for: Bool.self, with: UserDefaultsKey.isAuthorized.rawValue)
            return isAutherized ? try getTableViewController() : getAuthorizationViewController()
        } catch {
            return getAuthorizationViewController()
        }
    }
    
    private func createViewController<T: UIViewController>(type: T.Type) -> T {
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "\(type)") as! T
        return initialViewController
    }
    
    private func getAuthorizationViewController() -> UIViewController {
        let viewController = createViewController(type: AuthorizationViewController.self)
        viewController.authorizationService = authorizationService
        viewController.coordinator = self
        return viewController
    }
    
    private func getTableViewController() throws -> UIViewController {
        let tabBarController = UITabBarController()
        let navigationController = createViewController(type: UINavigationController.self)
        
        let homeViewController = navigationController.topViewController as! HomeViewController
        let token = try storageService.get(for: AccessTokenAPI.self, with: UserDefaultsKey.tokenAPI.rawValue)
        homeViewController.tableNetworkDataManager = .init(token)
        
        navigationController.viewControllers = [homeViewController]
        
        let galleryViewController = createViewController(type: GalleryViewController.self)
        
        let profileViewController = createViewController(type: ProfileViewController.self)
        profileViewController.authorizationService = authorizationService
        profileViewController.coordinator = self

        tabBarController.viewControllers = [navigationController, galleryViewController, profileViewController]
        
        return tabBarController
    }
    
}
