//
//  Photo.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import Foundation

struct Photo: Decodable {
    // Identifiers
    let id: String?
    
    // Content
    var title: String?
    var owner: String?
    var isPublic: Int?
    var isFriend: Int?

    // Other
    var secret: String?
    var server: String?
    var farm: Int?
    var isFamily: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        //case title = "title"
        case secret = "secret"
        case server = "server"
        //case owner = "owner"
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case farm = "farm"
        case isFamily = "isfamily"
    }
    
}

/*
Response: ["stat": ok, "photos": {
    page = 1;
    pages = 10;
    perpage = 100;
    photo =     (
                {
            farm = 66;
            id = 51401462177;
            isfamily = 0;
            isfriend = 0;
            ispublic = 1;
            owner = "132825197@N06";
            secret = 68975fa3a5;
            server = 65535;
            title = "Camping Sunsets";
        },
*/
