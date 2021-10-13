//
//  Tag.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import Foundation

struct Tag: Decodable {
    let content: String?
    let data: TagPhotosResponse?
    
    enum CodingKeys: String, CodingKey {
        case content = "_content"
        case data = "thm_data"
    }
}

struct TagPhotosResponse: Decodable {
    let data: TagPhotos
    
    struct TagPhotos: Decodable {
        let photos: [PhotoEntity]
        
        enum CodingKeys: String, CodingKey {
            case photos = "photo"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case data = "photos"
    }
}

/*
 Response: ["count": 10, "stat": ok, "hottags": {
     tag =     (
                 {
             "_content" = mountain;
             "thm_data" =             {
                 photos =                 {
                     photo =                     (
                                                 {
                             farm = 6;
                             id = 30006983321;
                             isfamily = 0;
                             isfriend = 0;
                             ispublic = 1;
                             owner = "57973623@N06";
                             secret = 4330984edb;
                             server = 5159;
                             title = "Looking west (Riffelsee, Switzerland)";
                             username = "<null>";
                         }
                     );
                 };
             };
         },
 */
