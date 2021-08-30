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
        request(
            type: .getFavorites,
            method: .GET,
            parser: ModelDeserializer<FavoritesResponse>()
        ) { result in
            completion(result.map { $0.data.photos })
        }
    }
    
    // Add photo to favorites 'flickr.favorites.add' (General screen)
    func addToFavorites(with photoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            parameters: parameters,
            type: .addToFavorites,
            method: .POST,
            parser: VoidDeserializer()
        ) { result in
            completion(result)
        }
    }
    
    // Remove photo from favorites 'flickr.favorites.remove' (General screen)
    func removeFromFavorites(with photoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            parameters: parameters,
            type: .removeFromFavorites,
            method: .POST,
            parser: VoidDeserializer()
        ) { result in
            completion(result)
        }
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
