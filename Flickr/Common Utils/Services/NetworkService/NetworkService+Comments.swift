//
//  NetworkService+Comments.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get photo comments list 'flickr.photos.comments.getList' (Post screen)
    func getPhotoComments(for photoId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        // Initialize parser
        let deserializer: ModelDeserializer<CommentsResponse> = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            params: parameters,
            requestMethod: .getPhotoComments,
            method: .GET,
            parser: deserializer.parse(data:)
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.data.comments))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Add new photo comment 'flickr.photos.comments.addComment' (Post screen) -> https://www.flickr.com/services/api/flickr.photos.comments.addComment.html
    func addPhotoComment(for photoId: String, comment: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Initialize parser
        let deserializer: VoidDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId,
            "comment_text": comment
        ]
        
        request(
            params: parameters,
            requestMethod: .addPhotoComment,
            method: .POST,
            parser: deserializer.parse(data:)
        ) { result in completion(result) }
    }
    
    // Delete comment 'flickr.photos.comments.deleteComment' (Post screen) -> https://www.flickr.com/services/api/flickr.photos.comments.deleteComment.html
    func deletePhotoComment(for commentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Initialize parser
        let deserializer: VoidDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "comment_id": commentId
        ]
        
        request(
            params: parameters,
            requestMethod: .deletePhotoComment,
            method: .POST,
            parser: deserializer.parse(data:)
        ) { result in completion(result) }
    }
    
    // The server JSON response decoder
    private struct CommentsResponse: Decodable {
        let data: Comments
        
        struct Comments: Decodable {
            let comments: [Comment]
            
            enum CodingKeys: String, CodingKey {
                case comments = "comment"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case data = "comments"
        }
    }
    
}
