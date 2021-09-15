//
//  AccountView.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

// MARK: - AccountView

@IBDesignable
class AccountView: UIView {
    
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
    
    func setup() {
        //Bundle.main.loadNibNamed("AccountView", owner: self, options: nil)
        let bundle = Bundle(for: AccountView.self)
        bundle.loadNibNamed("AccountView", owner: self, options: nil)
        ownerAvatar.layer.cornerRadius = ownerAvatar.frame.height / 2
        view.frame = bounds
        addSubview(view)
    }
    
}
