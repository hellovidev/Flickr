//
//  NetworkService+Favorites.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get list of faves 'flickr.favorites.getList' (Gallery screen)
    func getFavorites(complition: @escaping (Result<[Favorite], Error>) -> Void) {
        // Initialize parser
        let deserializer: FavoriteArrayDeserializer = .init()
        
        request(
            requestMethod: .getFavorites,
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
    
    // Add photo to favorites 'flickr.favorites.add' (General screen)
    func addToFavorites(with photoId: String, complition: @escaping (Result<Void, Error>) -> Void) {
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
        ) { result in
            switch result {
            case .success(let response):
                complition(.success(response))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    // Remove photo from favorites 'flickr.favorites.remove' (General screen)
    func removeFromFavorites(with photoId: String, complition: @escaping (Result<Void, Error>) -> Void) {
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
    private struct FavoriteArrayDeserializer: Deserializer {
        typealias Response = [Favorite]
        
        func parse(data: Data) throws -> [Favorite] {
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(FavoritesResponse.self, from: data)
                return response.data.photos
            } catch (let error) {
                throw ErrorMessage.error("The server response could not be parsed into an array of favorites.\nDescription: \(error)")
            }
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
