//
//  NetworkService+Photos.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get list of popular photos 'flickr.photos.getPopular' (General screen)
    func getPopularPosts(complition: @escaping (Result<[Photo], Error>) -> Void) {
        // Initialize parser
        let deserializer: PhotoArrayDeserializer = .init()
        
        request(
            requestMethod: .getPopularPosts,
            path: .requestREST,
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
    
    // Get photo 'flickr.photos.getInfo' (Post screen)
    func getPhotoById(with photoId: String, secret: String? = nil, complition: @escaping (Result<PhotoInfo, Error>) -> Void) {
        // Initialize parser
        let deserializer: PhotoInfoDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            params: parameters,
            requestMethod: .getPhotoInfo,
            path: .requestREST,
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
    
    // Get user photos 'flickr.people.getPhotos' (Gallery screen)
    func getUserPhotos(for userId: String, complition: @escaping (Result<[Photo], Error>) -> Void) {
        // Initialize parser
        let deserializer: PhotoArrayDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "user_id": userId
        ]
        
        request(
            params: parameters,
            requestMethod: .getUserPhotos,
            path: .requestREST,
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
    
    // Delete user 'flickr.photos.delete' (Gallery screen)
    func deletePhotoById(with photoId: String, complition: @escaping (Result<Void, Error>) -> Void) {
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
            path: .requestREST,
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
    private struct PhotoArrayDeserializer: Deserializer {
        typealias Response = [Photo]
        
        func parse(data: Data) throws -> [Photo] {
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(PhotosResponse.self, from: data)
                return response.data.photos
            } catch (let error) {
                throw ErrorMessage.error("The server response could not be parsed into an array of photos.\nDescription: \(error)")
            }
        }
    }
    
    private struct PhotoInfoDeserializer: Deserializer {
        typealias Response = PhotoInfo
        
        func parse(data: Data) throws -> PhotoInfo {
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(PhotoInfo.self, from: data)
                return response
            } catch (let error) {
                throw ErrorMessage.error("The server response could not be parsed into an array of photos.\nDescription: \(error)")
            }
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
