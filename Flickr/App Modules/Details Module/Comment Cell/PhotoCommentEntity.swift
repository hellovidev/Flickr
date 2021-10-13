//
//  PhotoComment.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 06.10.2021.
//

import UIKit

// MARK: - Comment Protocols

protocol CommentOwnerProtocol {
    var iconFarm: Int? { get set }
    var iconServer: String? { get set }
    var nsid: String? { get set }
}

protocol CommentProtocol {
    var ownerAvatar: UIImage? { get set }
    var username: String? { get set }
    var commentContent: String? { get set }
    var publishedAt: String? { get set }
}

// MARK: - PhotoCommentEntity

struct PhotoCommentEntity: CommentProtocol, CommentOwnerProtocol {
    
    var iconFarm: Int?
    
    var iconServer: String?
    
    var nsid: String?
    
    var ownerAvatar: UIImage?
    
    var username: String?
    
    var commentContent: String?
    
    var publishedAt: String?
    
}
