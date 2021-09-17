//
//  Coordinator.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 16.09.2021.
//

import UIKit

struct CoordinatorService {
    
    func makeKeyAndVisible(_ viewController: UIViewController, window: UIWindow) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
}
