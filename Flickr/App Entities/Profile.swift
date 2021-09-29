//
//  Profile.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import Foundation

class Profile: Decodable {
    
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

/*
 
 { "person": {
   "id": "193786693@N08", "nsid": "193786693@N08", "ispro": 0, "can_buy_pro": 1, "iconserver": 0, "iconfarm": 0, "path_alias": "", "has_stats": 0,
     "username": { "_content": "sergcom1998" },
     "realname": { "_content": "asd asd" },
     "mbox_sha1sum": { "_content": "aff1cc4637ad32aa5cf8d4915509004aeaab9ddb" },
     "location": { "_content": "" },
     "description": { "_content": "" },
     "photosurl": { "_content": "https:\/\/www.flickr.com\/photos\/193786693@N08\/" },
     "profileurl": { "_content": "https:\/\/www.flickr.com\/people\/193786693@N08\/" },
     "mobileurl": { "_content": "https:\/\/m.flickr.com\/photostream.gne?id=193693880" },
     "photos": {
       "firstdatetaken": { "_content": "2021-08-25 11:50:29" },
       "firstdate": { "_content": "1629917444" },
       "count": { "_content": 3 },
       "views": { "_content": 1 } }, "upload_count": 3, "upload_limit": "1000", "upload_limit_status": "below_limit", "is_cognito_user": 1, "all_rights_reserved_photos_count": 0, "has_adfree": 0, "has_free_standard_shipping": 0, "has_free_educational_resources": 0 }, "stat": "ok" }
 */


//
//struct Profile: Decodable {
//    // Identifiers
//    let id: String?
//    var nsid: String?
//    
//    // Location
//    var city: String?
//    var country: String?
//    var hometown: String?
//
//    // Contacts
//    var email: String?
//    
//    // Social media
//    var facebook: String?
//    var instagram: String?
//    var tumblr: String?
//    var twitter: String?
//    var pinterest: String?
//
//    // Information
//    var firstName: String?  //"first_name" = asd;
//    var lastName: String? //"last_name" = asd;
//    var joinDate: String? //"join_date" = 1629298161;
//    var profileDescrition: String? //"profile_description" = "";
//    var showcaseSet: String?  //"showcase_set" = 72157719697640819;
//    var showcaseSetTitle: String? //"showcase_set_title" = "Profile Showcase";
//    var occupation: String?
//}
//
///*
// Response: ["stat": ok, "profile": {
//    city = "<null>";
//    country = "<null>";
//    email = "sergcom1998@gmail.com";
//    facebook = "";
//    "first_name" = asd;
//    hometown = "";
//    id = "193786693@N08";
//    instagram = "";
//    "join_date" = 1629298161;
//    "last_name" = asd;
//    nsid = "193786693@N08";
//    occupation = "";
//    pinterest = "";
//    "profile_description" = "";
//    "showcase_set" = 72157719697640819;
//    "showcase_set_title" = "Profile Showcase";
//    tumblr = "";
//    twitter = "";
//}]
//*/
