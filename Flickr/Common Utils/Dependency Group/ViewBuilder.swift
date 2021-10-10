//
//  ViewBuilder.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 10.10.2021.
//

import Foundation

class ViewBuilder {
    
    func createAuthorizationViewController(coordinator: AuthorizationCoordinator) -> AuthorizationViewController {
        let authorizationViewController: AuthorizationViewController = Storyboard.authorization.instantiateViewController()
        authorizationViewController.viewModel = .init(coordinator: coordinator)
        return authorizationViewController
    }
    
    func createHomeViewController(coordinator: HomeCoordinator) -> HomeViewController {
        let homeViewController: HomeViewController = Storyboard.general.instantiateViewController()
        homeViewController.viewModel = .init(coordinator: coordinator)
        return homeViewController
    }
    
    func createGalleryViewController(coordinator: GeneralCoordinator, nsid: String) -> GalleryViewController {
        let galleryViewController: GalleryViewController = Storyboard.general.instantiateViewController()
        galleryViewController.viewModel = .init(coordinator: coordinator, nsid: nsid)
        return galleryViewController
    }
    
    func createProfileViewController(coordinator: GeneralCoordinator, nsid: String) -> ProfileViewController {
        let profileViewController: ProfileViewController = Storyboard.general.instantiateViewController()
        profileViewController.viewModel = .init(coordinator: coordinator, nsid: nsid)
        return profileViewController
    }
    
    func createDetailsViewController(coordinator: HomeCoordinator, id: String = "51552481986") -> DetailsViewController {
        let detailsViewController: DetailsViewController = Storyboard.general.instantiateViewController()
        detailsViewController.viewModel = .init(coordinator: coordinator, id: id)
        return detailsViewController
    }
    
}
