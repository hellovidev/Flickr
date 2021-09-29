//
//  Coordinator.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 16.09.2021.
//

import UIKit

struct CoordinatorService {
    
    private var window: UIWindow?
    
    private let storageService: LocalStorageServiceProtocol
    private let authorizationService: AuthorizationService
    
    init(storageService: LocalStorageServiceProtocol, authorizationService: AuthorizationService) {
        self.storageService = storageService
        self.window = UIApplication.shared.windows.first
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
        let viewController: AuthorizationViewController = Storyboard.main.instantiateViewController()
        viewController.viewModel = .init(coordinator: self, authorization: authorizationService)
        return viewController
    }
    
    private func getTableViewController() throws -> UIViewController {
        
        let token = try storageService.get(for: AccessTokenAPI.self, with: UserDefaultsKey.tokenAPI.rawValue)

        let homeViewController: HomeViewController = Storyboard.main.instantiateViewController(identifier: String(describing: HomeViewController.self))
        let homeViewModel = HomeViewModel()
        homeViewModel.postsNetworkManager = .init(token)
        homeViewController.viewModel = homeViewModel
        
        let homeNavigationController = UINavigationController.init(rootViewController: homeViewController)
        
        let galleryViewController: GalleryViewController = Storyboard.main.instantiateViewController()
        galleryViewController.viewModel = .init()
        let galleryNavigationController = UINavigationController.init(rootViewController: galleryViewController)
        
        let profileViewController: ProfileViewController = Storyboard.main.instantiateViewController()
        profileViewController.viewModel = .init(coordinator: self, authorization: authorizationService, token: token)
        let profileNavigationController = UINavigationController.init(rootViewController: profileViewController)

        let tabBarController: UITabBarController = .init()
        tabBarController.viewControllers = [homeNavigationController, galleryNavigationController, profileNavigationController]
        
        return tabBarController
    }
    
}
