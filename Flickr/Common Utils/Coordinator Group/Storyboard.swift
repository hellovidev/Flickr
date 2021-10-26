//
//  Storyboard.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

// MARK: - Storyboard

enum StoryboardIdentifier: String {
    case authorization = "Authorization"
    case general = "General"
}

struct Storyboard {
    
    static let authorization: UIStoryboard = .init(name: StoryboardIdentifier.authorization.rawValue, bundle: Bundle.main)
    
    static let general: UIStoryboard = .init(name: StoryboardIdentifier.general.rawValue, bundle: Bundle.main)
    
}

extension UIStoryboard {
    
    func instantiateViewController<T: UIViewController>() -> T {
        let className = String(describing: T.self)
        return self.instantiateViewController(withIdentifier: className) as! T
    }
    
}
