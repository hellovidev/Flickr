//
//  GeneralCoordinator.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 02.10.2021.
//

import UIKit

protocol GeneralCoordinatorDelegate: AnyObject {
    func coordinatorDidLogout(coordinator: GeneralCoordinator)
}

class GeneralCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = .init()
    
    var navigationController: UINavigationController
    
    var tabBarController: UITabBarController
    
    weak var parentCoordinator: ApplicationCoordinator?
    
    weak var delegate: GeneralCoordinatorDelegate?
    
    private let networkService: NetworkService
    
    private let nsid: String
    
    init(_ navigationController: UINavigationController, networkService: NetworkService, nsid: String) {
        self.navigationController = navigationController
        self.tabBarController = .init()
        self.networkService = networkService
        self.nsid = nsid
    }

    func start() {
        let homeNavigationController: UINavigationController = .init()
        let childHome = HomeCoordinator(homeNavigationController, networkService: networkService)
        childHome.parentCoordinator = self
        childCoordinators.append(childHome)
        childHome.start()
        
        let galleryViewController: GalleryViewController = Storyboard.general.instantiateViewController()
        galleryViewController.viewModel = .init(coordinator: self, nsid: nsid, network: networkService)
        let galleryNavigationController = UINavigationController.init(rootViewController: galleryViewController)
        
        let profileViewController: ProfileViewController = Storyboard.general.instantiateViewController()
        profileViewController.viewModel = .init(coordinator: self, nsid: nsid, networkService: networkService)
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
