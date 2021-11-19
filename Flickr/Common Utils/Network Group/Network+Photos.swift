//
//  Network+Photos.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

// MARK: - Network+Photos

extension Network {
    
    func getRecentPosts(page: Int, perPage: Int, completionHandler: @escaping (Result<[PhotoEntity], Error>) -> Void) {
        let parameters: [String: String] = [
            "per_page": String(perPage),
            "page": String(page)
        ]
        
        request(
            parameters: parameters,
            type: .getRecentPosts,
            method: .GET,
            parser: ModelDeserializer<PhotosResponse>()
        ) { result in
            completionHandler(result.map { $0.data.photos })
        }
    }
    
    func getUserPhotos(for id: String, completionHandler: @escaping (Result<[PhotoEntity], Error>) -> Void) {
        let parameters: [String: String] = [
            "user_id": id,
            "privacy_filter": "1",
            "per_page": "100",
            "extras": "date_upload"
        ]
        
        request(
            parameters: parameters,
            type: .getUserPhotos,
            method: .GET,
            parser: ModelDeserializer<PhotosResponse>()
        ) { result in
            completionHandler(result.map { $0.data.photos })
        }
    }
    
    // The server JSON response decoder
    private struct PhotosResponse: Decodable {
        let data: Photos
        
        struct Photos: Decodable {
            let photos: [PhotoEntity]
            
            enum CodingKeys: String, CodingKey {
                case photos = "photo"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case data = "photos"
        }
    }
    
    func getPhotoById(for id: String, secret: String? = nil, completionHandler: @escaping (Result<PhotoDetailsEntity, Error>) -> Void) {
        let parameters: [String: String] = [
            "photo_id": id
        ]
        
        request(
            parameters: parameters,
            type: .getPhotoInfo,
            method: .GET,
            parser: ModelDeserializer<PostDetailsResponse>()
        ) { result in
            completionHandler(result.map {
                return $0.photo
            })
        }
    }
    
    // The server JSON response decoder
    private struct PostDetailsResponse: Decodable {
        let photo: PhotoDetailsEntity
    }
    
//    func deletePhotoById(for id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
//        let parameters: [String: String] = [
//            "photo_id": id
//        ]
//        
//        request(
//            parameters: parameters,
//            type: .deletePhotoById,
//            method: .POST,
//            parser: VoidDeserializer(),
//            completionHandler: completionHandler
//        )
//    }
    
}
