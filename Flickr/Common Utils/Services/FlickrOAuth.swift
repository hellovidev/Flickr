//
//  NetworkService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit
import SafariServices

// MARK: - Network Layer (OAuth1.0)

class FlickrOAuth {
    
    static let shared = FlickrOAuth()
    
    // Methods to prepare API requests
    private let prepare: RequestPreparation = .init()
    
    // MARK: - Authorization State
    
    private enum AuthorizationState {
        case requestTokenRequested
        case authorizeRequested(handler: (URL) -> Void)
        case accessTokenRequested
        case successfullyAuthenticated
    }
    
    private var state: AuthorizationState?
    
    // MARK: - Additional Methods
    
    func isAuthorized() -> Bool {
        switch state {
        case .successfullyAuthenticated:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Structs For Responses
    
    // Structure to save request token response
    private struct RequestTokenOAuth {
        let token: String
        let secretToken: String
    }
        
    // Structure to build request arguments
    private struct ArgumentsAccessToken {
        var token: String
        var secretToken: String
        var verifier: String
    }
    
    // Structure to save access token response
    struct AccessTokenOAuth {
        let token: String
        let secretToken: String
        let userNSID: String
        let username: String
    }
    
    // MARK: - Public Methods API OAuth1.0
    
    func flickrLogin(presenter: UIViewController, complition: @escaping (Result<AccessTokenOAuth, Error>) -> Void) {
        // Check authorization state
        guard state == nil else {
            complition(.failure(ErrorMessage.error("User is already logged in.")))
            return
        }
        
        // Step #1: Getting request token
        getRequestToken() { [weak self] result in
            switch result {
            case .success(let requestToken):
                
                // Step #2: Website Confirmation
                self?.requestAuthorize(with: requestToken.token, presenter: presenter) { [weak self] result in
                    switch result {
                    case .success(let verifier):
                        let arguments = ArgumentsAccessToken(token: requestToken.token, secretToken: requestToken.secretToken, verifier: verifier)
                        
                        // Step #3: Getting access token
                        self?.getAccessToken(arguments: arguments) { [weak self] result in
                            switch result {
                            case .success(let accessToken):
                                self?.state = .successfullyAuthenticated
                                complition(.success(accessToken))
                            case .failure(let error):
                                complition(.failure(error))
                            }
                        }
                    case .failure(let error):
                        complition(.failure(error))
                    }
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    func flickrLogout() {
        state = nil
        // Sign out from 'Flickr' account
    }
    
    // MARK: - Steps OAuth1.0 Methods
    
    // Step #1: Getting Request Token
    private func getRequestToken(complition: @escaping (Result<RequestTokenOAuth, Error>) -> Void) {
        // Change authorization state
        state = .requestTokenRequested
        
        // Set extra parameters
        let parameters: [String: String] = [
            "oauth_callback": FlickrAPI.urlScheme.rawValue
        ]
        
        requestOAuth(params: parameters, path: .requestTokenOAuth, method: .POST) { result in
            switch result {
            case .success(let data):
                // Convert Data into String (Response: oauth_token=XXXX&oauth_token_secret=YYYY&oauth_callback_confirmed=true)
                guard let dataString = String(data: data, encoding: .utf8) else { return }
                
                // Convert response data to parameters
                let attributes = self.convertStringToParameters(dataString)
                guard let token = attributes["oauth_token"], let secretToken = attributes["oauth_token_secret"] else {
                    complition(.failure(ErrorMessage.error("Request token was not found.")))
                    return
                }
                
                complition(.success(RequestTokenOAuth(token: token, secretToken: secretToken)))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    // Parse request token response
    private func convertStringToParameters(_ response: String) -> [String: String] {
        // Breaks apart query string into a dictionary of values
        var parameters: [String: String] = [:]
        let items = response.split(separator: "&")
        for item in items {
            let combo = item.split(separator: "=")
            if combo.count == 2 {
                let key = "\(combo[0])"
                let value = "\(combo[1])"
                parameters[key] = value
            }
        }
        return parameters
    }
    
    // Step #2: Website Confirmation
    private func requestAuthorize(with token: String, presenter: UIViewController, complition: @escaping (Result<String, Error>) -> Void) {
        // Build website confirmation link for 'Safari'
        let urlString = "\(HttpEndpoint.baseDomain.rawValue)/services/oauth/authorize?oauth_token=\(token)&perms=write"
        guard let websiteConfirmationURL = URL(string: urlString) else { return }
        
        // Initialization 'Safari' object
        let safari = SFSafariViewController(url: websiteConfirmationURL)
        
        // Return 'ArgumentsAccessToken' after callback URL
        state = .authorizeRequested() { [weak self] url in
            // Dismiss the 'Safari' ViewController
            safari.dismiss(animated: true, completion: nil)
            
            guard let query = url.query else {
                complition(.failure(ErrorMessage.error("Parameters were not found after confirmation on the website.")))
                return
            }
            
            // Transformation: oauth-flickr://?oauth_token=XXXX&oauth_verifier=ZZZZ => ["oauth_token": "XXXX", "oauth_verifier": "YYYY"]
            let parameters = self?.convertStringToParameters(query)
            
            guard let verifier = parameters?["oauth_verifier"] else {
                complition(.failure(ErrorMessage.error("Parameters were not found after confirmation on the website.")))
                return
            }

            print("'verifier' -> Status: Complete")
            complition(.success(verifier))
        }
        
        // Async preview after receiving the link
        DispatchQueue.main.async {
            presenter.present(safari, animated: true, completion: nil)
        }
    }
    
    // Catch URL callback after confirmed authorization (Step #2: Website Confirmation)
    func handleURL(_ url: URL) {
        guard case let .authorizeRequested(handler) = state else {
            fatalError("Invalid authorization state.")
        }
        
        handler(url)
    }
    
    // Step #3: Getting Access Token
    private func getAccessToken(arguments: ArgumentsAccessToken, complition: @escaping (Result<AccessTokenOAuth, Error>) -> Void) {
        // Change authorization state
        state = .accessTokenRequested
        
        // Set extra parameters
        let parameters: [String: String] = [
            "oauth_token": arguments.token,
            "oauth_verifier": arguments.verifier
        ]
        
        requestOAuth(secretToken: arguments.secretToken, params: parameters, path: .accessTokenOAuth, method: .POST) { result in
            switch result {
            case .success(let data):
                // Convert Data into String (Response: oauth_token=XXXX&oauth_token_secret=YYYY&user_nsid=CCC&username=NNN)
                guard let dataString = String(data: data, encoding: .utf8) else { return }
                
                // Convert response data to parameters
                let attributes = self.convertStringToParameters(dataString)
                guard let token = attributes["oauth_token"], let secretToken = attributes["oauth_token_secret"], let userNSID = attributes["user_nsid"], let username = attributes["username"] else {
                    complition(.failure(ErrorMessage.error("Access token was not found.")))
                    return
                }
                
                complition(.success(AccessTokenOAuth(token: token, secretToken: secretToken, userNSID: userNSID, username: username)))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // MARK: - Request Configuration Methods
    
    private func requestOAuth(secretToken: String? = nil, params extraParameters: [String: String], path: HttpEndpoint.PathType, method: HttpMethodType, complition: @escaping (Result<Data, Error>) -> Void) {
        // Build base URL with path as parameter
        let urlString = HttpEndpoint.baseDomain.rawValue + path.rawValue
        
        // Create URL using endpoint
        guard let url = URL(string: urlString) else { return }
        
        // Initialize and configure URL request
        var urlRequest = URLRequest(url: url)
        
        // Set HTTP method to request using HttpMethodType with uppercase letters
        urlRequest.httpMethod = method.rawValue
        
        var parameters: [String: String] = [
            "oauth_consumer_key": FlickrAPI.consumerKey.rawValue,
            // Value 'nonce' can be any 32-bit string made up of random ASCII values
            "oauth_nonce": UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
            "oauth_version": "1.0"
        ]
        
        // Add to parameters extra values
        parameters = parameters.merging(extraParameters) { (current, _) in current }
        
        // Build the OAuth signature from parameters
        parameters["oauth_signature"] = prepare.createRequestSignature(httpMethod: method.rawValue, url: urlString, parameters: parameters, secretToken: secretToken)
        
        // Set parameters to HTTP body of URL request
        let header = "OAuth \(prepare.convertParametersToString(parameters, separator: ", "))"
        urlRequest.setValue(header, forHTTPHeaderField: "Authorization")
        
        // URL configuration
        let config = URLSessionConfiguration.default
        
        // Request creation
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                complition(.failure(ErrorMessage.error("HTTP response is empty.")))
                return
            }
            
            guard let data = data else {
                complition(.failure(ErrorMessage.error("Data response is empty.")))
                return
            }
            
            switch httpResponse.statusCode {
            case ..<200:
                complition(.failure(ErrorMessage.error("Informational message error (\(httpResponse.statusCode)).")))
            case ..<300:
                print("\(path == .requestTokenOAuth ? "'request_token'" : "'access_token'") -> Status: \(httpResponse.statusCode) OK")
                complition(.success(data))
            case ..<400:
                complition(.failure(ErrorMessage.error("Redirection message (\(httpResponse.statusCode)).")))
            case ..<500:
                complition(.failure(ErrorMessage.error("Client request error (\(httpResponse.statusCode)).")))
            case ..<600:
                complition(.failure(ErrorMessage.error("Internal server error (\(httpResponse.statusCode)).")))
            default:
                complition(.failure(ErrorMessage.error("Unknown status code (\(httpResponse.statusCode)).")))
            }
        }
        
        // Start request process
        task.resume()
    }
    
}
