//
//  Network+Profile.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

// MARK: - Network+Profile

extension Network {
    
    func getProfile(for id: String, completionHandler: @escaping (Result<ProfileEntity, Error>) -> Void) {
        let parameters: [String: String] = [
            "user_id": id,
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
