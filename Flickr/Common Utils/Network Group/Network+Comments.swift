//
//  Network+Comments.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

// MARK: - Network+Comments

extension Network {
    
    func getPhotoComments(for id: String, completionHandler: @escaping (Result<[CommentEntity]?, Error>) -> Void) {
        let parameters: [String: String] = [
            "photo_id": id
        ]
        
        request(
            parameters: parameters,
            type: .getPhotoComments,
            method: .GET,
            parser: ModelDeserializer<CommentsResponse>()
        ) { result in
            completionHandler(result.map { $0.comments?.comment })
        }
    }
    
    func addPhotoComment(for id: String, comment: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: String] = [
            "photo_id": id,
            "comment_text": comment
        ]
        
        request(
            parameters: parameters,
            type: .addPhotoComment,
            method: .POST,
            parser: VoidDeserializer(),
            completionHandler: completionHandler
        )
    }
    
    func deletePhotoComment(for id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: String] = [
            "comment_id": id
        ]
        
        request(
            parameters: parameters,
            type: .deletePhotoComment,
            method: .POST,
            parser: VoidDeserializer(),
            completionHandler: completionHandler
        )
    }
    
    // The server JSON response decoder
    private struct CommentsResponse: Decodable {
        let comments: Comments?
        
        struct Comments: Decodable {
            let comment: [CommentEntity]?
            
        }
    }
    
}
