//
//  Network+Favorites.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

// MARK: - Network+Favorites

extension Network {
    
    func getFavorites(completionHandler: @escaping (Result<[FavoriteEntity], Error>) -> Void) {
        request(
            type: .getFavorites,
            method: .GET,
            parser: ModelDeserializer<FavoritesResponse>()
        ) { result in
            completionHandler(result.map { $0.data.photos })
        }
    }
    
    func addToFavorites(for id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: String] = [
            "photo_id": id
        ]
        
        request(
            parameters: parameters,
            type: .addToFavorites,
            method: .POST,
            parser: VoidDeserializer(),
            completionHandler: completionHandler
        )
    }
    
    func removeFromFavorites(for id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: String] = [
            "photo_id": id
        ]
        
        request(
            parameters: parameters,
            type: .removeFromFavorites,
            method: .POST,
            parser: VoidDeserializer(),
            completionHandler: completionHandler
        )
    }
    
    // The server JSON response decoder
    private struct FavoritesResponse: Decodable {
        let data: Favorites
        
        struct Favorites: Decodable {
            let photos: [FavoriteEntity]
            
            enum CodingKeys: String, CodingKey {
                case photos = "photo"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case data = "photos"
        }
    }
    
}
