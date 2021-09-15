//
//  StateProvider.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

struct AuthorizationStateProvider {
    
    func checkStateAndReturnViewController() -> UIViewController {
        do {
            let userDefaultsStorageService = UserDefaultsStorageService()
            let state = try userDefaultsStorageService.pull(for: "state", type: Bool.self)
            
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
    
    private func createViewController<T: UIViewController>(type: T.Type) -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "\(type)") as! T
        return initialViewController
    }
    
}
