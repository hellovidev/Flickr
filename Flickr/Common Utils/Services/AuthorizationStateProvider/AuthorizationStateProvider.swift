//
//  StateProvider.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

//struct AuthorizationStateProvider {
//    
//    let storageService: LocalStorageServiceProtocol
//    private let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//    
//    func getInitialViewController() -> UIViewController {
//        do {
//            let state = try storageService.get(for: Bool.self, with: "state")
//            return state ? try getTableViewController() : getAuthorizationViewController()
//        } catch {
//            return getAuthorizationViewController()
//        }
//    }
//    
//    private func createViewController<T: UIViewController>(type: T.Type) -> T {
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "\(type)") as! T
//        return initialViewController
//    }
//    
//    private func getAuthorizationViewController() -> UIViewController {
//        let viewController = createViewController(type: AuthorizationViewController.self)
//        viewController.authorizationService = AuthorizationService(storageService: UserDefaultsStorageService())
//        return viewController
//    }
//    
//    private func getTableViewController() throws -> UIViewController {
//        let tabBarController = createViewController(type: UITabBarController.self)
//        let navigationController = tabBarController.viewControllers?.first as! UINavigationController
//        let viewController = navigationController.topViewController as! HomeViewController
//                   
//        let token = try storageService.get(for: AccessTokenAPI.self, with: "token")
//        viewController.manager = .init(token)
//        
//        return tabBarController
//    }
//    
//}
