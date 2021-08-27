//
//  NetworkService+Profile.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get current user profile 'flickr.profile.getProfile' (User screen)
    func getProfile(complition: @escaping (Result<Profile, Error>) -> Void) {
        // Initialize parser
        let deserializer: ProfileDeserializer = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "user_id": "access.nsid\(0)"
        ]
        
        request(
            params: parameters,
            requestMethod: .getProfile,
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
    
    // The server response parser
    private struct ProfileDeserializer: Deserializer {
        typealias Response = Profile
        
        func parse(data: Data) throws -> Profile {
            let decoder = JSONDecoder()
            // Decode with 'snake_case' strategy
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let response = try decoder.decode(ProfileResponse.self, from: data)
                return response.profile
            } catch (let error) {
                throw ErrorMessage.error("The server response could not be parsed into profile object.\nDescription: \(error)")
            }
        }
    }
    
    // The server JSON response decoder
    private struct ProfileResponse: Decodable {
        let profile: Profile
    }
    
}
