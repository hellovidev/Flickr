//
//  NetworkService+Upload.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 27.08.2021.
//

import UIKit

extension NetworkService {
    
    // Upload photo: https://www.flickr.com/services/api/upload.api.html
    func uploadNewPhoto(_ image: UIImage = UIImage(named: "TestImage")!, title: String, description: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "title": title,
            "description": description,
            "is_public": "1",
            "perms": "write"
        ]
        
        guard let imageData: Data = image.pngData() else { return }
        
        upload(
            parameters: parameters,
            file: imageData,
            endpoint: FlickrConstant.URL.uploadURL.rawValue,
            parser: VoidDeserializer(),
            completion: completion
        )
    }
    
}
