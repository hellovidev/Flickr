//
//  StateProvider.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

struct AuthorizationStateProvider {
    
    static func initialView() -> UIViewController {
        //Добавить на старте выбор начального экрана (написать отдельную структуру, которая будет делать проверку и возвращать результат этой проверки): если залогинен, то Home, иначе Login
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var state: Bool? = nil
        do {
            state = try StorageService.pull(type: Bool.self, for: "state")
        } catch(let storageError) {
            print(storageError)
        }
        
        if state ?? false {//FlickrOAuthService.shared.isAuthorized() {
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            return initialViewController
        } else {
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "AuthorizationViewController") as! AuthorizationViewController
            initialViewController.authorizationService = AuthorizationService()
            return initialViewController
        }

    }
    
}
