//
//  StateProvider.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

struct AuthorizationStateProvider {
    
    var storageService: StorageProtocol
    
    func getInitialViewController() -> UIViewController {
        do {
            let state = try storageService.pull(for: "state", type: Bool.self)
            
            if state {
                let tabBarController = createViewController(type: UITabBarController.self)
                let navigationController = tabBarController.viewControllers?.first as! UINavigationController
                let viewController = navigationController.topViewController as! HomeViewController

                
                
                //do {
                 //   let userDefaultsStorageService = UserDefaultsStorageService()
                    let token = try storageService.pull(for: "token", type: AccessTokenAPI.self)
                    
                    viewController.networkService = .init(
                        accessTokenAPI: token,
                        publicConsumerKey: FlickrConstant.Key.consumerKey.rawValue,
                        secretConsumerKey: FlickrConstant.Key.consumerSecretKey.rawValue
                    )
                    
                //} catch {
               //     showAlert(title: "Error", message: error.localizedDescription, button: "OK")
                //}
                
                //tabBarController.selectedViewController = navigationController
              //   = NetworkService
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
