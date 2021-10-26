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
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ownerAvatar: UIImageView!
    @IBOutlet weak var ownerAccountName: UILabel!
    @IBOutlet weak var ownerLocation: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
        setupOwnerAvatar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configuration()
        setupOwnerAvatar()
    }
    
    private func configuration() {
        let selfClass = type(of: self)
        let bundle = Bundle(for: selfClass)
        bundle.loadNibNamed("\(selfClass)", owner: self)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    private func setupOwnerAvatar() {
        ownerAvatar.layer.cornerRadius = ownerAvatar.frame.height / 2
    }
    
}
