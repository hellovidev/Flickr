//
//  NetworkService+Delete.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 01.10.2021.
//

import Foundation

extension NetworkService {
    
    func deletePhotoById(_ id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: String] = [
            "photo_id": id
        ]
        
        request(
            parameters: parameters,
            type: .deletePhotoById,
            method: .POST,
            parser: VoidDeserializer(),
            completion: completion
        )
    }
    
}
