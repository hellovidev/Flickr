//
//  AuthorizationService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 08.09.2021.
//

import UIKit

class AuthorizationService: AuthorizationProtocol {
    
    func login(presenter: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
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
                completion(.success(Void()))
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
