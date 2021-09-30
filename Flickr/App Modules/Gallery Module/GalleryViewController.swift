//
//  GalleryViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - GalleryViewController

class GalleryViewController: UIViewController {
    
    var viewModel: GalleryViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }

}
