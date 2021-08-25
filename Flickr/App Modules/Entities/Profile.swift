//
//  Profile.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import Foundation

struct Profile: Decodable {
    // Identifiers
    let id: String?
    var nsid: String?
    
    // Location
    var city: String?
    var country: String?
    var hometown: String?

    // Contacts
    var email: String?
    
    // Social media
    var facebook: String?
    var instagram: String?
    var tumblr: String?
    var twitter: String?
    var pinterest: String?

    // Information
    var firstName: String?  //"first_name" = asd;
    var lastName: String? //"last_name" = asd;
    var joinDate: String? //"join_date" = 1629298161;
    var profileDescrition: String? //"profile_description" = "";
    var showcaseSet: String?  //"showcase_set" = 72157719697640819;
    var showcaseSetTitle: String? //"showcase_set_title" = "Profile Showcase";
    var occupation: String?
}

/*
 Response: ["stat": ok, "profile": {
    city = "<null>";
    country = "<null>";
    email = "sergcom1998@gmail.com";
    facebook = "";
    "first_name" = asd;
    hometown = "";
    id = "193786693@N08";
    instagram = "";
    "join_date" = 1629298161;
    "last_name" = asd;
    nsid = "193786693@N08";
    occupation = "";
    pinterest = "";
    "profile_description" = "";
    "showcase_set" = 72157719697640819;
    "showcase_set_title" = "Profile Showcase";
    tumblr = "";
    twitter = "";
}]
*/
