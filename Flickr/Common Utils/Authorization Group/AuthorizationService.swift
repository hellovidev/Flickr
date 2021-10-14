//
//  AuthorizationService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 08.09.2021.
//

import UIKit

// MARK: - AuthorizationProtocol

protocol AuthorizationProtocol {
    func login(presenter: UIViewController, completion: @escaping (Result<Void, Error>) -> Void)
    func logout()
}

// MARK: - AuthorizationService

class AuthorizationService: AuthorizationProtocol, DependencyProtocol {
    
    private let storageService: LocalStorageServiceProtocol
    
    private let flickrOAuthService: FlickrOAuthService
    
    init(storageService: LocalStorageServiceProtocol) {
        self.storageService = storageService
        self.flickrOAuthService = .init(storageService: storageService)
    }
    
    func login(presenter: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        flickrOAuthService.flickrLogin(presenter: presenter) { [weak self] result in
            switch result {
            case .success(let accessOAuthToken):
                do {
                    let token = AccessTokenAPI(token: accessOAuthToken.token, secret: accessOAuthToken.secretToken, nsid: accessOAuthToken.userNSID)
                    try self?.storageService.set(for: token, with: UserDefaults.Keys.tokenAPI.rawValue)
                    
                    guard let nsid = token.nsid.removingPercentEncoding else {
                        completion(.failure(NetworkManagerError.nilResponseData))
                        return
                    }
                    
                    try self?.storageService.set(for: nsid, with: UserDefaults.Keys.nsid.rawValue)
                    completion(.success(Void()))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        flickrOAuthService.flickrLogout()
        storageService.removeAll()
    }
    
    func handleURL(_ url: URL) {
        flickrOAuthService.handleURL(url)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
