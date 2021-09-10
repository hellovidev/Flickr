//
//  UIViewController+Alert.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 09.09.2021.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, button: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(.init(title: button, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
    }
    
}
