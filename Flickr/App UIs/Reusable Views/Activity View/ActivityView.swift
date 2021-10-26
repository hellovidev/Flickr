//
//  ActivityView.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 13.10.2021.
//

import UIKit

// MARK: - ActivityView

class ActivityView: UIView {
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let boundingBoxView = UIView(frame: .zero)
    
    init() {
        super.init(frame: .zero)
        
        boundingBoxView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        boundingBoxView.layer.cornerRadius = 12.0
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.color = .white
        
        addSubview(boundingBoxView)
        addSubview(activityIndicatorView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        boundingBoxView.frame.size.width = 64
        boundingBoxView.frame.size.height = 64
        boundingBoxView.frame.origin.x = ceil((bounds.width / 2.0) - (boundingBoxView.frame.width / 2.0))
        boundingBoxView.frame.origin.y = ceil((bounds.height / 2.0) - (boundingBoxView.frame.height / 2.0))
        
        activityIndicatorView.frame.origin.x = ceil((bounds.width / 2.0) - (activityIndicatorView.frame.width / 2.0))
        activityIndicatorView.frame.origin.y = ceil((bounds.height / 2.0) - (activityIndicatorView.frame.height / 2.0))
    }
    
}
