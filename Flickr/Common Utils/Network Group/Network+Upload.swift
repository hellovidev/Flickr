//
//  Network+Upload.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 27.08.2021.
//

import Foundation

// MARK: - Network+Upload

extension Network {
    
    func uploadImage(_ data: Data, title: String, description: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
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
            completionHandler: completionHandler
        )
    }
    
}
