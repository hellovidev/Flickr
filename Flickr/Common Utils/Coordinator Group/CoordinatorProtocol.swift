//
//  CoordinatorProtocol.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 02.10.2021.
//

import UIKit

// MARK: - CoordinatorProtocol

protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    func start()
}
