//
//  CommentEntity.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import UIKit

// MARK: - CommentEntity

struct CommentEntity: Decodable, CommentOwnerProtocol {

    let id: String?

    var content: String?
    
    var dateCreate: String?
    
    var permalink: String?
    
    var nsid: String?
    
    var authorIsDeleted: Int?
    
    var authorName: String?
    
    var realName: String?
    
    var iconFarm: Int?
    
    var iconServer: String?
    
    var pathAlias: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case content = "_content"
        case dateCreate = "datecreate"
        case permalink = "permalink"
        case nsid = "author"
        case authorIsDeleted = "author_is_deleted"
        case authorName = "authorname"
        case realName = "realname"
        case iconFarm = "iconfarm"
        case iconServer = "iconserver"
        case pathAlias = "path_alias"
    }
    
}
