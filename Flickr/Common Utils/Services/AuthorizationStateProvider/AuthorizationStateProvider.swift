//
//  StateProvider.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

struct AuthorizationStateProvider {
    
    static func checkStateAndReturnViewController() -> UIViewController {
        do {
            let state = try UserDefaultsStorageService.pull(type: Bool.self, for: "state")
            
            if state {
                let viewController = createViewController(type: UITabBarController.self)
                return viewController
            } else {
                let viewController = createViewController(type: AuthorizationViewController.self)
                viewController.authorizationService = AuthorizationService()
                return viewController
            }
        } catch {
            let viewController = createViewController(type: AuthorizationViewController.self)
            viewController.authorizationService = AuthorizationService()
            return viewController
        }
    }
    
    private static func createViewController<T: UIViewController>(type: T.Type) -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "\(type)") as! T
        return initialViewController
    }
    
}
