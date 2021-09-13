//
//  AccountView.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

class AccountView: UIView {
    
    private let XIB_NAME = "AccountView"

    @IBOutlet var view: UIView!
    @IBOutlet weak var ownerAvatar: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: XIB_NAME, bundle: Bundle.main)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        addSubview(view)
    }
    
}
