//
//  Photo.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import Foundation

struct Photo: Decodable {
    
    let id: String?
    
    var title: String?
    
    var owner: String?
    
    var isPublic: Int?
    
    var isFriend: Int?

    var secret: String?
    
    var server: String?
    
    var farm: Int?
    
    var isFamily: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case secret = "secret"
        case server = "server"
        case owner = "owner"
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case farm = "farm"
        case isFamily = "isfamily"
    }
    
}
