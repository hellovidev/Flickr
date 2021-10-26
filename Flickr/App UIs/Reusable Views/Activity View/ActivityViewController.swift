//
//  ActivityViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 01.10.2021.
//

import UIKit

// MARK: - ActivityViewController

class ActivityViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        
        let activityView: ActivityView = .init()
        view = activityView
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
