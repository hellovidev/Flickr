//
//  NavigationLogotype.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 11.10.2021.
//

import UIKit

class NavigationLogotype: UIView {
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageName.logotype.rawValue)
        imageView.center = self.convert(self.center, from: imageView)
        
        self.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
