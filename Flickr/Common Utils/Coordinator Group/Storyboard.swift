//
//  Storyboard.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

enum StoryboardType: String {
    case main = "Main"
}

struct Storyboard {
    static let main: UIStoryboard = .init(name: StoryboardType.main.rawValue, bundle: Bundle.main)
}

extension UIStoryboard {
    
    func instantiateViewController<T>() -> T {
        let id = String(describing: T.self)
        return self.instantiateViewController(withIdentifier: id) as! T
    }
    
}
