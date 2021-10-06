//
//  PhotoComment.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 06.10.2021.
//

import UIKit

protocol CommentProtocol {
    var ownerAvatar: UIImage? { get set }
    var username: String? { get set }
    var commentContent: String? { get set }
    var publishedAt: String? { get set }
}

struct PhotoComment: CommentProtocol {
    var ownerAvatar: UIImage?
    var username: String?
    var commentContent: String?
    var publishedAt: String?
}
