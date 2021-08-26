//
//  Favorite.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import Foundation

struct Favorite: Decodable {
    // Identifiers
    let id: String?
    
    // Content
    var title: String?
    var owner: String?
    var isPublic: Int?
    var isFriend: Int?
    let dateFaved: String?

    // Other
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
        case dateFaved = "date_faved"
    }
    
}

/*
 Response: ["stat": ok, "photos": {
     page = 1;
     pages = 1;
     perpage = 100;
     photo =     (
                 {
             "date_faved" = 1629915199;
             farm = 66;
             id = 51399635930;
             isfamily = 0;
             isfriend = 0;
             ispublic = 1;
             owner = "117708192@N04";
             secret = 3a274cc4a2;
             server = 65535;
             title = "Entering Paradise";
         },
 */
