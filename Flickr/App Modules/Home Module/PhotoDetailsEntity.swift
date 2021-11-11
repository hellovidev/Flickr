//
//  PhotoDetailsEntity.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

//class PhotoDetails: Codable {
//    var id: String?
//    var title: String?
//}

// MARK: - PhotoDetailsEntity

public struct PhotoDetailsEntity: Codable, Hashable {
    
//    public static func == (lhs: PhotoDetailsEntity, rhs: PhotoDetailsEntity) -> Bool {
//        return lhs.id == rhs.id && lhs.owner == rhs.owner
//    }
    
    public init() {}
    
    public var id: String?
    
    var secret: String?
    
    var server: String?
    
    var farm: Int?
    
    var dateUploaded: String?
    
    var isFavorite: Int?
    
    var license: String?
    
    var safetyLevel: String?
    
    var rotation: Int?
    
    var originalSecret: String?
    
    var originalFormat: String?
    
    public var owner: Owner?
    
    var title: Title?
    
    var description: Description?
    
    var visibility: Visibility?
    
    var dates: PostDate?
    
    var permissions: Permissions?
    
    var views: String?
    
    var editability: Editability?
    
    var publicEditability: PublicEditability?
    
    var usage: Usage?
    
    var comment: Comment?
    
    var people: People?
    
    var tags: TagArray?
    
    var urls: PhotoURL?
    
    var media: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case secret = "secret"
        case server = "server"
        case farm = "farm"
        case dateUploaded = "dateuploaded"
        case isFavorite = "isfavorite"
        case license = "license"
        case safetyLevel = "safety_level"
        case rotation = "rotation"
        case originalSecret = "originalsecret"
        case originalFormat = "originalformat"
        case owner = "owner"
        case title = "title"
        case description = "description"
        case visibility = "visibility"
        case dates = "dates"
        case permissions = "permissions"
        case views = "views"
        case editability = "editability"
        case publicEditability = "publiceditability"
        case usage = "usage"
        case comment = "comments"
        case people = "people"
        case tags = "tags"
        case urls = "urls"
        case media = "media"
    }
    
    // MARK: - Owner
    
    public struct Owner: Codable, Hashable {
        public var nsid: String? //???
        var username: String?
        var realName: String?
        var location: String?
        var iconServer: String?
        var iconFarm: Int?
        var pathAlias: String?
        
        enum CodingKeys: String, CodingKey {
            case nsid = "nsid"
            case username = "username"
            case realName = "realname"
            case location = "location"
            case iconServer = "iconserver"
            case iconFarm = "iconfarm"
            case pathAlias = "path_alias"
        }
    }
    
    // MARK: - Title
    
    struct Title: Codable, Hashable {
        var content: String?
        
        enum CodingKeys: String, CodingKey {
            case content = "_content"
        }
    }
    
    // MARK: - Description
    
    struct Description: Codable, Hashable {
        var content: String?
        
        enum CodingKeys: String, CodingKey {
            case content = "_content"
        }
    }
    
    // MARK: - Visibility
    
    struct Visibility: Codable, Hashable {
        var isPublic: Int?
        var isFriend: Int?
        var isFamily: Int?
        
        enum CodingKeys: String, CodingKey {
            case isPublic = "ispublic"
            case isFriend = "isfriend"
            case isFamily = "isfamily"
        }
    }
    
    // MARK: - Dates
    
    struct PostDate: Codable, Hashable {
        let posted: String?
        var taken: String?
        var takenUnknown: String?
        var lastUpdate: String?
        
        enum CodingKeys: String, CodingKey {
            case posted = "posted"
            case taken = "taken"
            case takenUnknown = "takenunknown"
            case lastUpdate = "lastupdate"
        }
    }
    
    // MARK: - Permissions
    
    struct Permissions: Codable, Hashable {
        var permComment: Int?
        var permAddMeta: Int?
        
        enum CodingKeys: String, CodingKey {
            case permComment = "permcomment"
            case permAddMeta = "permaddmeta"
        }
    }
    
    // MARK: - Editability
    
    struct Editability: Codable, Hashable {
        var canComment: Int?
        var canAddMeta: Int?
        
        enum CodingKeys: String, CodingKey {
            case canComment = "cancomment"
            case canAddMeta = "canaddmeta"
        }
    }
    
    // MARK: - PublicEditability
    
    struct PublicEditability: Codable, Hashable {
        var canComment: Int?
        var canAddMeta: Int?
        
        enum CodingKeys: String, CodingKey {
            case canComment = "cancomment"
            case canAddMeta = "canaddmeta"
        }
    }
    
    // MARK: - Usage
    
    struct Usage: Codable, Hashable {
        var canDownload: Int?
        var canBlog: Int?
        var canPrint: Int?
        var canShare: Int?
        
        enum CodingKeys: String, CodingKey {
            case canDownload = "candownload"
            case canBlog = "canblog"
            case canPrint = "canprint"
            case canShare = "canshare"
        }
    }
    
    // MARK: - CommentArray
    
    struct Comment: Codable, Hashable {
        var content: String?
        
        enum CodingKeys: String, CodingKey {
            case content = "_content"
        }
    }
    
    // MARK: - People
    
    struct People: Codable, Hashable {
        var hasPeople: Int?
        
        enum CodingKeys: String, CodingKey {
            case hasPeople = "haspeople"
        }
    }
    
    // MARK: - TagArray
    
    struct TagArray: Codable, Hashable {
        var tagsArray: [TagObject]?
        
        struct TagObject: Codable, Hashable {
            let id: String?
            var author: String?
            var authorName: String?
            var raw: String?
            var content: String?
            
            enum CodingKeys: String, CodingKey {
                case id = "id"
                case author = "author"
                case authorName = "authorname"
                case raw = "raw"
                case content = "_content"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case tagsArray = "tag"
        }
    }
    
    // MARK: - PhotoURL
    
    struct PhotoURL: Codable, Hashable {
        var url: [URLObject]?
        
        struct URLObject: Codable, Hashable {
            var type: String?
            var content: String?
            
            enum CodingKeys: String, CodingKey {
                case type = "type"
                case content = "_content"
            }
        }
    }
    
}
