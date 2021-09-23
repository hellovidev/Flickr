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
    
    private func getAuthorizationViewController() -> UIViewController {
        let viewController: AuthorizationViewController = storyboard.instantiateViewController()
        viewController.authorizationService = authorizationService
        viewController.coordinator = self
        return viewController
    }
    
    private func getTableViewController() throws -> UIViewController {
        
        let token = try storageService.get(for: AccessTokenAPI.self, with: UserDefaultsKey.tokenAPI.rawValue)

        let homeViewController = storyboard.instantiateViewController(identifier: String(describing: HomeViewController.self)) { coder -> HomeViewController? in
            let homeViewModel = HomeViewModel()
            homeViewModel.postsNetworkManager = .init(token)
            return HomeViewController(coder: coder, viewModel: homeViewModel)
        }
        
        let navigationController = UINavigationController.init(rootViewController: homeViewController)
        
        let galleryViewController: GalleryViewController = storyboard.instantiateViewController()
        
        let profileViewController: ProfileViewController = storyboard.instantiateViewController()
        profileViewController.authorizationService = authorizationService
        profileViewController.coordinator = self

        let tabBarController: UITabBarController = .init()
        tabBarController.viewControllers = [navigationController, galleryViewController, profileViewController]
        
        return tabBarController
    }
    
}

extension UIStoryboard {
    
    func instantiateViewController<T>() -> T {
        let id = String(describing: T.self)
        return self.instantiateViewController(withIdentifier: id) as! T
    }
    
}
