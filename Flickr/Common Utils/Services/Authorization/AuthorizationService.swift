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
    func signup(presenter: UIViewController)
    func logout()
}

// MARK: - AuthorizationService

class AuthorizationService: AuthorizationProtocol {
    
    //static let shared = AuthorizationService()
    
    private let storageService: LocalStorageServiceProtocol
    private let flickrOAuthService: FlickrOAuthService
    
    init() {
        self.storageService = UserDefaultsStorageService()
        self.flickrOAuthService = .init()
        self.flickrOAuthService.storageService = storageService
    }
    
    func login(presenter: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        flickrOAuthService.flickrLogin(presenter: presenter) { [weak self] result in
            switch result {
            case .success(let accessOAuthToken):
                do {
                    let token = AccessTokenAPI(token: accessOAuthToken.token, secret: accessOAuthToken.secretToken, nsid: accessOAuthToken.userNSID)
                    try self?.storageService.set(for: token, with: UserDefaultsKey.tokenAPI.rawValue)
                    completion(.success(Void()))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signup(presenter: UIViewController) {
        let signupWebView: WKWebViewController = .init(endpoint: FlickrConstant.URL.signup.rawValue)
        signupWebView.delegate = self
        presenter.present(signupWebView, animated: true, completion: nil)
    }
    
    func logout() {
        flickrOAuthService.flickrLogout()
        storageService.removeAll()
    }
    
    func handleURL(_ url: URL) {
        flickrOAuthService.handleURL(url)
    }
    
}

// MARK: - WKWebViewDelegate

extension AuthorizationService: WKWebViewControllerDelegate {
    
    func close(viewController: WKWebViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
