//
//  NetworkService+Photos.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get list of popular photos 'flickr.photos.getPopular' (General screen)
    func getRecentPosts(completion: @escaping (Result<[Photo], Error>) -> Void) {
        // Initialize parser
        let deserializer: ModelDeserializer<PhotosResponse> = .init()
        
        request(
            for: .request,
            methodAPI: .getRecentPosts,
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
    
    // Get photo 'flickr.photos.getInfo' (Post screen)
    func getPhotoById(with photoId: String, secret: String? = nil, completion: @escaping (Result<PhotoInfo, Error>) -> Void) {
        // Initialize parser
        let deserializer: ModelDeserializer<PhotoInfo> = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            for: .request,
            methodAPI: .getPhotoInfo,
            parameters: parameters,
            token: access.token,
            secret: access.secret,
            consumerKey: FlickrAPI.consumerKey.rawValue,
            secretConsumerKey: FlickrAPI.consumerSecretKey.rawValue,
            httpMethod: .GET,
            formatType: .JSON,
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
            for: .request,
            methodAPI: .getUserPhotos,
            parameters: parameters,
            token: access.token,
            secret: access.secret,
            consumerKey: FlickrAPI.consumerKey.rawValue,
            secretConsumerKey: FlickrAPI.consumerSecretKey.rawValue,
            httpMethod: .POST,
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
            for: .request,
            methodAPI: .deleteUserPhotoById,
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
