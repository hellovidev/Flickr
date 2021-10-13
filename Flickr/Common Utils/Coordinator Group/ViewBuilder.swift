//
//  ViewBuilder.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 10.10.2021.
//

import Foundation

class ViewBuilder {
    
    private let dependencyContainer: DependencyContainer
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    func registerNewDependency<T: DependencyProtocol>(_ dependency: T) {
        self.dependencyContainer.register(dependency)
    }
        
    func createAuthorizationViewController(coordinator: AuthorizationCoordinator) -> AuthorizationViewController {
        let authorizationViewController: AuthorizationViewController = Storyboard.authorization.instantiateViewController()
        authorizationViewController.viewModel = .init(coordinator: coordinator)
        return authorizationViewController
    }
    
    func createHomeViewController(coordinator: HomeCoordinator) -> HomeViewController {
        let homeViewController: HomeViewController = Storyboard.general.instantiateViewController()
        let network: NetworkService = dependencyContainer.retrive()
        homeViewController.viewModel = .init(coordinator: coordinator, network: network)
        return homeViewController
    }
    
    func createGalleryViewController(coordinator: GeneralCoordinator) -> GalleryViewController {
        let galleryViewController: GalleryViewController = Storyboard.general.instantiateViewController()
        let network: NetworkService = dependencyContainer.retrive()
        galleryViewController.viewModel = .init(coordinator: coordinator, network: network)
        return galleryViewController
    }
    
    func createProfileViewController(coordinator: GeneralCoordinator) -> ProfileViewController {
        let profileViewController: ProfileViewController = Storyboard.general.instantiateViewController()
        let network: NetworkService = dependencyContainer.retrive()
        profileViewController.viewModel = .init(coordinator: coordinator, network: network)
        return profileViewController
    }
    
    func createDetailsViewController(coordinator: HomeCoordinator, id: String = "51552481986") -> DetailsViewController {
        let detailsViewController: DetailsViewController = Storyboard.general.instantiateViewController()
        let network: NetworkService = dependencyContainer.retrive()
        detailsViewController.viewModel = .init(coordinator: coordinator, id: id, network: network)
        return detailsViewController
    }
    
}
