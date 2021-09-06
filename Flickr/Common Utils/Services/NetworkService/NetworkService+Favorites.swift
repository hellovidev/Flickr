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
            type: FlickrConstant.Method.getFavorites.rawValue,
            endpoint: FlickrConstant.URL.requestURL.rawValue,
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
            type: FlickrConstant.Method.addToFavorites.rawValue,
            endpoint: FlickrConstant.URL.requestURL.rawValue,
            method: .POST,
            parser: VoidDeserializer(),
            completion: completion
        )
    }
    
    // Remove photo from favorites 'flickr.favorites.remove' (General screen)
    func removeFromFavorites(with photoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            parameters: parameters,
            type: FlickrConstant.Method.removeFromFavorites.rawValue,
            endpoint: FlickrConstant.URL.requestURL.rawValue,
            method: .POST,
            parser: VoidDeserializer(),
            completion: completion
        )
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
