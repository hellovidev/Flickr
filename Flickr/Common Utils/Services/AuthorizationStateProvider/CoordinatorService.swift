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
    
    init(storageService: LocalStorageServiceProtocol) {
        self.storageService = storageService
        self.window = UIApplication.shared.windows.first
        self.storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    func redirectToInitialViewController() {
        let viewController = getInitialViewController()
        makeKeyAndVisible(viewController)
        
        UIView.transition(with: window!, duration: 0.2, options: [.transitionCrossDissolve], animations: {}, completion: nil)
    }
    
    private func makeKeyAndVisible(_ viewController: UIViewController) {
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
    
    private func getInitialViewController() -> UIViewController {
        do {
            let state = try storageService.get(for: Bool.self, with: "state")
            return state ? try getTableViewController() : getAuthorizationViewController()
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
        viewController.authorizationService = AuthorizationService(storageService: UserDefaultsStorageService())
        return viewController
    }
    
    private func getTableViewController() throws -> UIViewController {
        let tabBarController = createViewController(type: UITabBarController.self)
        let navigationController = tabBarController.viewControllers?.first as! UINavigationController
        let viewController = navigationController.topViewController as! HomeViewController
                   
        let token = try storageService.get(for: AccessTokenAPI.self, with: "token")
        viewController.manager = .init(token)
        
        return tabBarController
    }
    
}
