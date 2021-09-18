//
//  StateProvider.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

struct AuthorizationStateProvider {
    
    var storageService: LocalStorageServiceProtocol!
    
    func getInitialViewController() -> UIViewController {
        do {
            let state = try storageService.get(for: Bool.self, with: "state")
            
            if state {
                let tabBarController = createViewController(type: UITabBarController.self)
                let navigationController = tabBarController.viewControllers?.first as! UINavigationController
                let viewController = navigationController.topViewController as! HomeViewController
                
                let token = try storageService.get(for: AccessTokenAPI.self, with: "token")
                
                viewController.networkService = .init(
                    accessTokenAPI: token,
                    publicConsumerKey: FlickrConstant.Key.consumerKey.rawValue,
                    secretConsumerKey: FlickrConstant.Key.consumerSecretKey.rawValue
                )
                
                return tabBarController
            } else {
                let viewController = createViewController(type: AuthorizationViewController.self)
                viewController.authorizationService = AuthorizationService(storageService: UserDefaultsStorageService())
                return viewController
            }
        } catch {
            let viewController = createViewController(type: AuthorizationViewController.self)
            viewController.authorizationService = AuthorizationService(storageService: UserDefaultsStorageService())
            return viewController
        }
    }
    
    private func createViewController<T: UIViewController>(type: T.Type) -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "\(type)") as! T
        return initialViewController
    }
    
}
