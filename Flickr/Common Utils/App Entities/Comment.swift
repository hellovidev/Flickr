//
//  Comment.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import Foundation

struct Comment: Decodable {
    // Identifiers
    let id: String?

    // Content
    var content: String?
    var dateCreate: String?
    var permalink: String?
    
    // Author
    var author: String?
    var authorIsDeleted: Int?
    var authorName: String?
    var realName: String?
    
    // Other
    var iconFarm: Int?
    var iconServer: String?
    var pathAlias: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case content = "_content"
        case dateCreate = "datecreate"
        case permalink = "permalink"
        case author = "author"
        case authorIsDeleted = "author_is_deleted"
        case authorName = "authorname"
        case realName = "realname"
        case iconFarm = "iconfarm"
        case iconServer = "iconserver"
        case pathAlias = "path_alias"
    }
}

/*
Response: ["stat": ok, "comments": {
    comment =     (
                {
            "" = "Umm, I'm not sure, can I get back to you on that one?";
             = "35468159852@N01";
            "" = 0;
             = "Rev Dan Catt";
             = 1141841470;
             = 3;
             = 2865;
            id = "6065-109722179-72057594077818641";
            "" = revdancatt;
             = "https://www.flickr.com/photos/straup/109722179/#comment72057594077818641";
             = "Daniel Catt";
        },
*/
