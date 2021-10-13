//
//  Network+Delete.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 01.10.2021.
//

import Foundation

// MARK: - Network+Delete

extension Network {
    
    func deletePhotoById(_ id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: String] = [
            "photo_id": id
        ]
        
        request(
            parameters: parameters,
            type: .deletePhotoById,
            method: .POST,
            parser: VoidDeserializer(),
            completionHandler: completionHandler
        )
    }
    
}
