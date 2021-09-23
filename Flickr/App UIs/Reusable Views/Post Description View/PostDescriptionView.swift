//
//  MetaView.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 14.09.2021.
//

import UIKit

// MARK: - MetaView

@IBDesignable
class PostDescriptionView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let bundle = Bundle(for: PostDescriptionView.self)
        bundle.loadNibNamed("PostDescriptionView", owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }
    
}
