//
//  NetworkService+Photos.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get list of popular photos 'flickr.photos.getPopular' (General screen)
    func getPopularPosts(completion: @escaping (Result<[Photo], Error>) -> Void) {
        // Initialize parser
        let deserializer: ModelDeserializer<PhotosResponse> = .init()
        
        request(
            requestMethod: .getPopularPosts,
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
    
    // Get photo 'flickr.photos.getInfo' (Post screen)
    func getPhotoById(with photoId: String, secret: String? = nil, completion: @escaping (Result<PhotoInfo, Error>) -> Void) {
        // Initialize parser
        let deserializer: ModelDeserializer<PhotoInfo> = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            params: parameters,
            requestMethod: .getPhotoInfo,
            method: .GET,
            parser: deserializer.parse(data:)
        ) { result in completion(result) }
    }
    
    // Get user photos 'flickr.people.getPhotos' (Gallery screen)
    func getUserPhotos(for userId: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        // Initialize parser
        let deserializer: ModelDeserializer<PhotosResponse> = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "user_id": userId
        ]
        
        request(
            params: parameters,
            requestMethod: .getUserPhotos,
            method: .POST,
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
    
    // Delete user 'flickr.photos.delete' (Gallery screen)
    func deletePhotoById(with photoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Initialize parser
        let deserializer: VoidDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId,
            "perms": "delete"
        ]
        
        request(
            params: parameters,
            requestMethod: .deleteUserPhotoById,
            method: .POST,
            parser: deserializer.parse(data:)
        ) { result in completion(result) }
    }
    
    // Build link to get image: https://www.flickr.com/services/api/misc.urls.html
    private struct PhotosResponse: Decodable {
        let data: Photos
        
        struct Photos: Decodable {
            let photos: [Photo]
            
            enum CodingKeys: String, CodingKey {
                case photos = "photo"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case data = "photos"
        }
    }
    
}
