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
        // Initialize parser
        let deserializer: ModelDeserializer<TagsResponse> = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "count": String(count)
        ]
        
        request(
            params: parameters,
            requestMethod: .getHotTags,
            method: .GET,
            parser: deserializer.parse(data:)
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.data.tags))
            case .failure(let error):
                completion(.failure(error))
            }
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
    
//    struct ResponseCatcher: Decodable {
//        let parent: ResponseCatcherChild
//        
//        enum CodingKeys: String, CodingKey {
//            required init(parentKey: String) {
//                NetworkService.ResponseCatcher.CodingKeys(rawValue: NetworkService.ResponseCatcher.CodingKeys.parent = parentKey) ?? <#default value#>
//            }
//            
//            case parent = ""
//        }
//        
//        struct ResponseCatcherChild: Decodable {
//            let child: [String]
//            
//            enum CodingKeys: String, CodingKey {
//                case child = ""
//            }
//        }
//    }
    
}
