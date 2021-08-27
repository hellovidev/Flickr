//
//  NetworkService+Upload.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 27.08.2021.
//

import UIKit

extension NetworkService {
    
    // Upload photo: https://www.flickr.com/services/api/upload.api.html
    func uploadNewPhoto(_ image: UIImage = UIImage(named: "TestImage")!, title: String, description: String, complition: @escaping (Result<Void, Error>) -> Void) {
        // Initialize parser
        let deserializer: VoidDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "title": title,
            "description": description,
            "is_public": "1",
            "perms": "write"
        ]
        
        guard let imageData: Data = image.pngData() else { return }
        
        uploadRequest(
            params: parameters,
            for: imageData,
            method: .POST,
            parser: deserializer.parse(data:)
        ) { result in
            switch result {
            case .success(let response):
                complition(.success(response))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
}
