//
//  HomeViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.09.2021.
//

import UIKit

struct Filter {
    let title: String
    let color: UIColor
}

enum HomeRoute {
    case `self`
    case fullPost(id: String)
}

class HomeViewModel {
    
    var postsNetworkManager: PostsNetworkManager!
    var router: Observable<HomeRoute> = .init(.`self`)
    
    let filters: [Filter] = [
        Filter(title: "50", color: .systemBlue),
        Filter(title: "100", color: .systemPink),
        Filter(title: "200", color: .systemRed),
        Filter(title: "400", color: .systemTeal)
    ]

}
