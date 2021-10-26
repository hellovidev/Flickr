//
//  UploadButtonView.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 30.09.2021.
//

import Foundation

import UIKit

// MARK: - UploadButtonView

@IBDesignable
class UploadButtonView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var uploadPhotoButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
        setupUploadButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configuration()
        setupUploadButton()
    }
    
    private func configuration() {
        let selfClass = type(of: self)
        let bundle = Bundle(for: selfClass)
        bundle.loadNibNamed("\(selfClass)", owner: self)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    private func setupUploadButton() {
        uploadPhotoButton.layer.cornerRadius = uploadPhotoButton.frame.height / 2
        uploadPhotoButton.layer.borderColor = UIColor.systemGray3.cgColor
        uploadPhotoButton.layer.borderWidth = 1
    }
    
}
