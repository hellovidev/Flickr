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
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(
            parameters: parameters,
            type: .getPhotoComments,
            method: .GET,
            parser: ModelDeserializer<CommentsResponse>()
        ) { result in
            completion(result.map { $0.data.comments })
        }
    }
    
    // Add new photo comment 'flickr.photos.comments.addComment' (Post screen) -> https://www.flickr.com/services/api/flickr.photos.comments.addComment.html
    func addPhotoComment(for photoId: String, comment: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "photo_id": photoId,
            "comment_text": comment
        ]
        
        request(
            parameters: parameters,
            type: .addPhotoComment,
            method: .POST,
            parser: VoidDeserializer()
        ) { result in
            completion(result)
        }
    }
    
    // Delete comment 'flickr.photos.comments.deleteComment' (Post screen) -> https://www.flickr.com/services/api/flickr.photos.comments.deleteComment.html
    func deletePhotoComment(for commentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "comment_id": commentId
        ]
        
        request(
            parameters: parameters,
            type: .deletePhotoComment,
            method: .POST,
            parser: VoidDeserializer()
        ) { result in
            completion(result)
        }
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
