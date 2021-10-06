//
//  HomeCoordinator.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 04.10.2021.
//

import UIKit

class HomeCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = .init()
    
    var navigationController: UINavigationController
        
    weak var parentCoordinator: GeneralCoordinator?
    
    private let networkService: NetworkService
            
    init(_ navigationController: UINavigationController, networkService: NetworkService) {
        self.navigationController = navigationController
        self.networkService = networkService
    }

    func start() {
        let homeViewController: HomeViewController = Storyboard.general.instantiateViewController()
        homeViewController.viewModel = .init(coordinator: self, networkService: networkService)
        navigationController.setViewControllers([homeViewController], animated: true)
    }
    
    func redirectDetails(details: PostDetails) {
        let detailsViewController: DetailsViewController = Storyboard.general.instantiateViewController()
        detailsViewController.viewModel = .init(coordinator: self, details: details, networkService: networkService)
        detailsViewController.viewModel.delegate = self //???
        navigationController.pushViewController(detailsViewController, animated: true)
    }
        
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}


// MARK: - PostViewControllerDelegate

extension HomeCoordinator: DetailsViewControllerDelegate {
    
    func close() {
        navigationController.popViewController(animated: true)
    }
    
}
