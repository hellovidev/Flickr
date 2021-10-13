//
//  NetworkService+Profile.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get current user profile 'flickr.profile.getProfile' (User screen)
    func getProfile(for userId: String, completionHandler: @escaping (Result<ProfileEntity, Error>) -> Void) {
        // Push some additional parameters
        let parameters: [String: String] = [
            "user_id": userId,
        ]
        
        request(
            parameters: parameters,
            type: .getProfile,
            method: .GET,
            parser: ModelDeserializer<ProfileResponse>()
        ) { result in
            completionHandler(result.map { $0.person })
        }
    }
    
    // The server JSON response decoder
    private struct ProfileResponse: Decodable {
        let person: ProfileEntity
    }
    
}
