//
//  GeneralCoordinator.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 02.10.2021.
//

import UIKit

// MARK: - GeneralCoordinator

protocol GeneralCoordinatorDelegate: AnyObject {
    func coordinatorDidLogout(coordinator: GeneralCoordinator)
}

class GeneralCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = .init()
    
    var navigationController: UINavigationController
    
    var tabBarController: UITabBarController
    
    weak var parentCoordinator: ApplicationCoordinator?
    
    weak var delegate: GeneralCoordinatorDelegate?
    
    private let viewBuilder: ViewBuilder
    
    init(_ navigationController: UINavigationController, viewBuilder: ViewBuilder) {
        self.navigationController = navigationController
        self.tabBarController = .init()
        self.viewBuilder = viewBuilder
    }
    
    func start() {
        let homeNavigationController: UINavigationController = .init()
        let childHome = HomeCoordinator(homeNavigationController, viewBuilder: viewBuilder)
        childHome.parentCoordinator = self
        childCoordinators.append(childHome)
        childHome.start()
        
        let galleryViewController = viewBuilder.createGalleryViewController(coordinator: self)
        let galleryNavigationController = UINavigationController.init(rootViewController: galleryViewController)
        
        let profileViewController = viewBuilder.createProfileViewController(coordinator: self)
        let profileNavigationController = UINavigationController.init(rootViewController: profileViewController)
        
        let tabBarControllers = [homeNavigationController, galleryNavigationController, profileNavigationController]
        tabBarController.setViewControllers(tabBarControllers, animated: true)
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

extension GeneralCoordinator {
    
    func didLogout() {
        parentCoordinator?.childDidFinish(self)
        parentCoordinator?.coordinatorDidLogout(coordinator: self)
    }
    
}
