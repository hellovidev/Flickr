//
//  NetworkService+Upload.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 27.08.2021.
//

import UIKit

extension NetworkService {
        
    // Upload photo: https://www.flickr.com/services/api/upload.api.html
    func uploadImage(_ data: Data, title: String, description: String, completion: @escaping (Result<Void, Error>) -> Void) {

        let parameters: [String: String] = [
            "title": title,
            "description": description,
            "is_public": "1",
            "perms": "write"
        ]
                
        upload(
            parameters: parameters,
            file: data,
            parser: VoidDeserializer(),
            completion: completion
        )
    }
    
}
