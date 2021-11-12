//
//  ViewBanner.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/12/21.
//

import UIKit

class ViewBanner {
    
    // MARK: - Constants
    
    private var bannerButton = UIButton(type: .system)
    private let greenColor = UIColor(red: 63, green: 161, blue: 81, alpha: 1)
    private let warningColor = UIColor(red: 252, green: 140, blue: 38, alpha: 1)
    private let errorColor = UIColor(red: 252, green: 66, blue: 54, alpha: 1)
    
    private var window: UIWindow?
        
    init(title: String) {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        guard let mainWindow = window else { return }
        self.window = mainWindow
        
        bannerButton.frame = CGRect(x: mainWindow.center.x / 1.6, y: 120, width: 150, height: 45)
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
        
        mainWindow.addSubview(bannerButton)
        
        bannerButton.isHidden = true
    }

    func show() {
        bannerButton.isHidden = false
        
        UIView.animate(withDuration: 1, delay: 0.3, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            self.bannerButton.frame.origin.y -= 3
        })
    }
    
    func hide() {
        bannerButton.isHidden = true
    }

    var onPressed: (() -> ())?
    
    @objc func onClick() {
        self.onPressed?()
    }
}

