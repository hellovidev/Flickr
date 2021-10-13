//
//  AddButtonView.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 30.09.2021.
//

import Foundation

import UIKit

// MARK: - AddButtonView

@IBDesignable
class AddButtonView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var addNewButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let bundle = Bundle(for: AddButtonView.self)
        bundle.loadNibNamed("AddButtonView", owner: self, options: nil)
        
        addNewButton.layer.cornerRadius = addNewButton.frame.height / 2
        addNewButton.layer.borderColor = UIColor.systemGray3.cgColor
        addNewButton.layer.borderWidth = 1
        
        view.frame = bounds
        addSubview(view)
    }
    
}
