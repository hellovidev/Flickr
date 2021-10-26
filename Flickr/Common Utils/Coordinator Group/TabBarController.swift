//
//  TabBarController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 13.10.2021.
//

import UIKit

// MARK: - TabBarController

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var selfTap: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        
        if tabBarIndex == 0 && selfTap {
            let indexPath: IndexPath = .init(row: 0, section: 0)
            let navigationView = viewController as? UINavigationController
            let finalViewController = navigationView?.viewControllers[0] as? HomeViewController
            finalViewController?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        selfTap = tabBarController.selectedIndex == 0 ? true : false
        return true
    }
    
}

