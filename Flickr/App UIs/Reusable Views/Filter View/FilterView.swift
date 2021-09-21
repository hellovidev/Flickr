//
//  FilterView.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 21.09.2021.
//

import UIKit

// MARK: - FilterView

@IBDesignable
class FilterView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var filterName: UILabel!
    @IBOutlet weak var filterImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let bundle = Bundle(for: FilterView.self)
        bundle.loadNibNamed("FilterView", owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }
    
}
