//
//  StoryboardProtocol.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 02.10.2021.
//

import UIKit

enum StoryboardIdentifier: String {
    case authorization = "Authorization"
    case general = "General"
    case main = "Main"
}

protocol StoryboardProtocol {
    static func instantiate(from storyboard: StoryboardIdentifier) -> Self
}

extension StoryboardProtocol where Self: UIViewController {
    
    static func instantiate<T: UIViewController>(from storyboard: StoryboardIdentifier) -> T {
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: Bundle.main)

        let className = String(describing: T.self)

        // Instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! T
    }
    
}
