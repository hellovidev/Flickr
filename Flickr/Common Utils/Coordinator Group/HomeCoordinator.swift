//
//  HomeCoordinator.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 04.10.2021.
//

import UIKit

// MARK: - HomeCoordinator

class HomeCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = .init()
    
    var navigationController: UINavigationController
    
    weak var parentCoordinator: GeneralCoordinator?
    
    private let viewBuilder: ViewBuilder
    
    init(_ navigationController: UINavigationController, viewBuilder: ViewBuilder) {
        self.navigationController = navigationController
        self.viewBuilder = viewBuilder
    }
    
    func start() {
        let homeViewController = viewBuilder.createHomeViewController(coordinator: self)
        navigationController.setViewControllers([homeViewController], animated: true)
    }
    
    func redirectDetails(id: String) {
        let detailsViewController = viewBuilder.createDetailsViewController(coordinator: self, id: id)
        detailsViewController.viewModel.delegate = self
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
