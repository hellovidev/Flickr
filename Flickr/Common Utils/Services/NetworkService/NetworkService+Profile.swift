//
//  NetworkService+Profile.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

extension NetworkService {
    
    // Get current user profile 'flickr.profile.getProfile' (User screen)
    func getProfile(for userId: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        // Initialize parser
        let deserializer: ModelDeserializer<ProfileResponse> = .init()
        
        // Push some additional parameters
        let parameters: [String: String] = [
            "user_id": userId,
            "method": Constant.FlickrMethod.getProfile.rawValue,
        ]
        
//        request(
//            params: parameters,
//            requestMethod: .getProfile,
//            method: .GET,
//            parser: deserializer.parse(data:)
//        ) { result in
//            switch result {
//            case .success(let response):
//                completion(.success(response.profile))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
        
        request(
            for: .request,
            methodAPI: .getProfile,
            parameters: parameters,
            token: access.token,
            secret: access.secret,
            consumerKey: FlickrAPI.consumerKey.rawValue,
            secretConsumerKey: FlickrAPI.consumerSecretKey.rawValue,
            httpMethod: .GET,
            formatType: .json,
            parser: deserializer.parse(data:)
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // The server JSON response decoder
    private struct ProfileResponse: Decodable {
        let profile: Profile
    }
    
}
