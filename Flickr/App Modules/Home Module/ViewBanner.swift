//
//  ViewBanner.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/12/21.
//

import UIKit

class ViewBanner {
    
    private var bannerButton = UIButton(type: .system)
    
    init(view: UIView, title: String) {       
        bannerButton.frame = CGRect(x: view.center.x - 75, y: 120, width: 150, height: 45)
        bannerButton.layer.cornerRadius = bannerButton.frame.height / 2
        bannerButton.backgroundColor = .systemGray6
        bannerButton.setTitle(title, for: .normal)
        bannerButton.setTitleColor(.black, for: .normal)
        
        bannerButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        bannerButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        bannerButton.layer.shadowOpacity = 1.0
        bannerButton.layer.shadowRadius = 10.0
        bannerButton.layer.masksToBounds = false
        
        bannerButton.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        
        view.addSubview(bannerButton)
        hide()
    }
    
    func show() {
        bannerButton.frame.origin.y -= 200
        bannerButton.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [.curveEaseIn], animations: { [weak self] in
            self?.bannerButton.frame.origin.y += 200
        })
        
        UIView.animate(withDuration: 1, delay: 0.3, options: [.autoreverse, .repeat, .allowUserInteraction], animations: { [weak self] in
            self?.bannerButton.frame.origin.y -= 3
        })
    }
    
    func hide() {
        bannerButton.isHidden = true
    }
    
    var onPressed: (() -> ())?
    
    @objc func onClick() {
        onPressed?()
    }
    
}
