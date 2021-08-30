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
        request(
            type: .getRecentPosts,
            method: .GET,
            parser: ModelDeserializer<PhotosResponse>()
        ) { result in
            completion(result.map { $0.data.photos })
        }
    }
    
    // Get photo 'flickr.photos.getInfo' (Post screen)
    func getPhotoById(with photoId: String, secret: String? = nil, completion: @escaping (Result<PhotoInfo, Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            parameters: parameters,
            type: .getPhotoInfo,
            method: .GET,
            parser: ModelDeserializer<PhotoInfo>()
        ) { result in
            completion(result)
        }
    }
    
    // Get user photos 'flickr.people.getPhotos' (Gallery screen)
    func getUserPhotos(for userId: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "user_id": userId
        ]
        
        request(
            parameters: parameters,
            type: .getUserPhotos,
            method: .GET,
            parser: ModelDeserializer<PhotosResponse>()
        ) { result in
            completion(result.map { $0.data.photos })
        }
    }
    
    // Delete user 'flickr.photos.delete' (Gallery screen)
    func deletePhotoById(with photoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId,
            "perms": "delete"
        ]
        
        request(
            parameters: parameters,
            type: .deleteUserPhotoById,
            method: .POST,
            parser: VoidDeserializer()
        ) { result in
            completion(result)
        }
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
