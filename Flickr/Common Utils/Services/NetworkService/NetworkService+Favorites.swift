//
//  NetworkService+Favorites.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get list of faves 'flickr.favorites.getList' (Gallery screen)
    func getFavorites(completion: @escaping (Result<[Favorite], Error>) -> Void) {
        // Initialize parser
        let deserializer: ModelDeserializer<FavoritesResponse> = .init()
        
        request(
            requestMethod: .getFavorites,
            method: .GET,
            parser: deserializer.parse(data:)
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.data.photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Add photo to favorites 'flickr.favorites.add' (General screen)
    func addToFavorites(with photoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Initialize parser
        let deserializer: VoidDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            params: parameters,
            requestMethod: .addToFavorites,
            method: .POST,
            parser: deserializer.parse(data:)
        ) { result in completion(result) }
    }
    
    // Remove photo from favorites 'flickr.favorites.remove' (General screen)
    func removeFromFavorites(with photoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Initialize parser
        let deserializer: VoidDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            params: parameters,
            requestMethod: .removeFromFavorites,
            method: .POST,
            parser: deserializer.parse(data:)
        ) { result in completion(result) }
    }
    
    // The server JSON response decoder
    private struct FavoritesResponse: Decodable {
        let data: Favorites
        
        struct Favorites: Decodable {
            let photos: [Favorite]
            
            enum CodingKeys: String, CodingKey {
                case photos = "photo"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case data = "photos"
        }
    }
    
}
