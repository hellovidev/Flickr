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
            for: .request,
            methodAPI: .getFavorites,
            token: access.token,
            secret: access.secret,
            consumerKey: FlickrAPI.consumerKey.rawValue,
            secretConsumerKey: FlickrAPI.consumerSecretKey.rawValue,
            httpMethod: .GET,
            formatType: .JSON,
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
            for: .request,
            methodAPI: .addToFavorites,
            parameters: parameters,
            token: access.token,
            secret: access.secret,
            consumerKey: FlickrAPI.consumerKey.rawValue,
            secretConsumerKey: FlickrAPI.consumerSecretKey.rawValue,
            httpMethod: .POST,
            formatType: .JSON,
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
            for: .request,
            methodAPI: .removeFromFavorites,
            parameters: parameters,
            token: access.token,
            secret: access.secret,
            consumerKey: FlickrAPI.consumerKey.rawValue,
            secretConsumerKey: FlickrAPI.consumerSecretKey.rawValue,
            httpMethod: .POST,
            formatType: .JSON,
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
