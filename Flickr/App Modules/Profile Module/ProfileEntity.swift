//
//  Profile.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import Foundation

class ProfileEntity: Decodable {
    
    let id: String?
    
    let nsid: String?
    
    let iconServer: String?
    
    let iconFarm: Int?
    
    let realName: RealName?
    
    let description: Description?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case nsid = "nsid"
        case iconServer = "iconserver"
        case iconFarm = "iconfarm"
        case realName = "realname"
        case description = "description"
    }
    
    struct Description: Decodable {
        
        let content: String?
        
        enum CodingKeys: String, CodingKey {
            case content = "_content"
        }
        
    }
    
    struct RealName: Decodable {
        
        let content: String?
        
        enum CodingKeys: String, CodingKey {
            case content = "_content"
        }
        
    }
    
}
