//
//  AuthorizationService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 08.09.2021.
//

import UIKit

protocol AuthorizationProtocol {
    static func login(presenter: UIViewController, completion: @escaping (Result<String, Error>) -> Void)
    static func signup()
    static func logout()
}

struct AuthorizationService: AuthorizationProtocol {

    static func login(presenter: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        FlickrOAuthService.shared.flickrLogin(presenter: presenter) { result in
            switch result {
            case .success(let access):
                do {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(access)
                    UserDefaults.standard.set(data, forKey: "token")
                } catch {
                    completion(.failure(error))
                }
                completion(.success("Authorization success."))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func signup() {
        //
    }
    
    static func logout() {
        FlickrOAuthService.shared.flickrLogout()
    }
    
    
}
