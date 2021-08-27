//
//  NetworkService+Tags.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get list of hot tags 'flickr.places.tagsForPlace' (General screen)
    func getHotTags(count: Int = 10, complition: @escaping (Result<[Tag], Error>) -> Void) {
        // Initialize parser
        let deserializer: TagArrayDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "count": String(count)
        ]
        
        request(
            params: parameters,
            requestMethod: .getHotTags,
            path: .requestREST,
            method: .GET,
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
    
    // The server response parser
    private struct TagArrayDeserializer: Deserializer {
        typealias Response = [Tag]
        
        func parse(data: Data) throws -> [Tag] {
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(TagsResponse.self, from: data)
                return response.data.tags
            } catch (let error) {
                throw ErrorMessage.error("The server response could not be parsed into an array of tags.\nDescription: \(error)")
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
    
}
