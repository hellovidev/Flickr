//
//  AuthorizationService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 08.09.2021.
//

import UIKit

// MARK: - AuthorizationService

class AuthorizationService: AuthorizationProtocol {
    
    private let storageService: LocalStorageServiceProtocol
    
    init(storageService: LocalStorageServiceProtocol) {
        self.storageService = storageService
    }
    
    func login(presenter: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        FlickrOAuthService.shared.flickrLogin(presenter: presenter) { [weak self] result in
            switch result {
            case .success(let accessOAuthToken):
                do {
                    let token = AccessTokenAPI(token: accessOAuthToken.token, secret: accessOAuthToken.secretToken, nsid: accessOAuthToken.userNSID)
                    try self?.storageService.set(for: token, with: "token") //save(object: token, with: "token")
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
        FlickrOAuthService.shared.flickrLogout()
        storageService.remove(for: "state")
        storageService.remove(for: "token")
    }
    
    func handleURL(_ url: URL) {
        FlickrOAuthService.shared.handleURL(url)
    }
    
}

// MARK: - WKWebViewDelegate

extension AuthorizationService: WKWebViewControllerDelegate {
    
    func close(viewController: WKWebViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Protocols

protocol AuthorizationProtocol {
    func login(presenter: UIViewController, completion: @escaping (Result<Void, Error>) -> Void)
    func signup(presenter: UIViewController)
    func logout()
}
