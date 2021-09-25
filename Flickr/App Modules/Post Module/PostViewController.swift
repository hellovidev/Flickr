//
//  PostViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - PostViewController

class PostViewController: UIViewController {
    
    var viewModel: PostViewModel!
    weak var delegate: PostViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }

}

// MARK: - PostViewControllerDelegate

protocol PostViewControllerDelegate: AnyObject {
    func close(viewController: PostViewController)
}
