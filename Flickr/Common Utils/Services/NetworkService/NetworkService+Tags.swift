//
//  NetworkService+Tags.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get list of hot tags 'flickr.places.tagsForPlace' (General screen)
    func getHotTags(count: Int = 10, completion: @escaping (Result<[Tag], Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "count": String(count)
        ]
        
        request(
            parameters: parameters,
            type: FlickrConstant.Method.getHotTags.rawValue,
            endpoint: FlickrConstant.URL.requestURL.rawValue,
            method: .GET,
            parser: ModelDeserializer<TagsResponse>()
        ) { result in
            completion(result.map { $0.data.tags })
        }
    }
    
    // The server JSON response decoder
    private struct TagsResponse: Decodable {
        let data: Tags
        
        private enum CodingKeys: String, CodingKey {
            case data = "hottags"
        }
        
        struct Tags: Decodable {
            let tags: [Tag]
            
            enum CodingKeys: String, CodingKey {
                case tags = "tag"
            }
        }
    }
    
}
