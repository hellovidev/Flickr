//
//  DetailsEntity.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 13.10.2021.
//

import UIKit

// MARK: - DetailsEntity

struct DetailsEntity {
    
    var id: String?
    
    var secret: String?
    
    var server: String?
    
    var image: UIImage?
    
    var title: String?
    
    var description: String?
    
    var publishedAt: String?
    
    var isFavourite: Bool?
    
    var owner: Owner?
    
    var comments: [CommentProtocol & CommentOwnerProtocol]?
    
    struct Owner {
        var avatar: UIImage?
        var realName: String?
        var username: String?
        var location: String?
        var iconFarm: Int?
        var iconServer: String?
        var nsid: String?
    }
    
}
