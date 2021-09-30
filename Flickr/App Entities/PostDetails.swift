    //
    //  PhotoInfo.swift
    //  Flickr
    //
    //  Created by Sergei Romanchuk on 26.08.2021.
    //

    import Foundation

    /// Post Details Object.
    /// Use this object to get post deatils by id.
    /// - Note: https://www.flickr.com/services/api/explore/flickr.photos.getInfo.
    class PostDetails: Decodable {
        
        let id: String?
        
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
        
        var owner: Owner?
        
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
        
        var notes: NoteArray?
        
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
            case notes = "notes"
            case people = "people"
            case tags = "tags"
            case urls = "urls"
            case media = "media"
        }
        
        // MARK: - Owner
        
        struct Owner: Decodable {
            
            let nsid: String?
            
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
        
        struct Title: Decodable {
            
            var content: String?
            
            enum CodingKeys: String, CodingKey {
                case content = "_content"
            }
            
        }
        
        // MARK: - Description
        
        struct Description: Decodable {
            
            var content: String?
            
            enum CodingKeys: String, CodingKey {
                case content = "_content"
            }
            
        }
        
        // MARK: - Visibility

        struct Visibility: Decodable {
            
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

        struct PostDate: Decodable {
            
            let posted: String?
            
            var taken: String?
            
            //var takenGranularity: String?
            
            var takenUnknown: String?
            
            var lastUpdate: String?
            
            enum CodingKeys: String, CodingKey {
                case posted = "posted"
                case taken = "taken"
                //case takenGranularity = "takengranularity"
                case takenUnknown = "takenunknown"
                case lastUpdate = "lastupdate"
            }
            
        }
        
        // MARK: - Permissions
        
        struct Permissions: Decodable {
            
            var permComment: Int?
            
            var permAddMeta: Int?
            
            enum CodingKeys: String, CodingKey {
                case permComment = "permcomment"
                case permAddMeta = "permaddmeta"
            }
            
        }
        
        // MARK: - Editability
        
        struct Editability: Decodable {

            var canComment: Int?
            
            var canAddMeta: Int?
            
            enum CodingKeys: String, CodingKey {
                case canComment = "cancomment"
                case canAddMeta = "canaddmeta"
            }
            
        }
        
        // MARK: - PublicEditability
        
        struct PublicEditability: Decodable {
            
            var canComment: Int?
            
            var canAddMeta: Int?
            
            enum CodingKeys: String, CodingKey {
                case canComment = "cancomment"
                case canAddMeta = "canaddmeta"
            }
            
        }
        
        // MARK: - Usage
        
        struct Usage: Decodable {
            
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
        
        struct Comment: Decodable {
            
            var content: String?
            
            enum CodingKeys: String, CodingKey {
                case content = "_content"
            }
            
        }
        
        // MARK: - NoteArray
        
        struct NoteArray: Decodable {
            
            var noteArray: [NoteObject]?
            
            struct NoteObject: Decodable {
                // Note object properties
            }
            
            enum CodingKeys: String, CodingKey {
                case noteArray = "note"
            }
            
        }
        
        // MARK: - People

        struct People: Decodable {
            
            var hasPeople: Int?
            
            enum CodingKeys: String, CodingKey {
                case hasPeople = "haspeople"
            }
            
        }
        
        // MARK: - TagArray
        
        struct TagArray: Decodable {
            
            var tagsArray: [TagObject]?
            
            struct TagObject: Decodable {
                
                let id: String?
                
                var author: String?
                
                var authorName: String?
                
                var raw: String?
                
                var content: String?
                
                //var machineTag: Bool?
                
                enum CodingKeys: String, CodingKey {
                    case id = "id"
                    case author = "author"
                    case authorName = "authorname"
                    case raw = "raw"
                    case content = "_content"
                    //case machineTag = "machine_tag"
                }
                
            }
            
            enum CodingKeys: String, CodingKey {
                case tagsArray = "tag"
            }
            
        }
        
        // MARK: - PhotoURL

        struct PhotoURL: Decodable {
            
            var url: [URLObject]?
            
            struct URLObject: Decodable {
                
                var type: String?
                
                var content: String?
                
                enum CodingKeys: String, CodingKey {
                    case type = "type"
                    case content = "_content"
                }
                
            }
            
        }
        
    }
