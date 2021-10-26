//
//  NetworkService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit
import SafariServices

// MARK: - OAuth 1.0

class FlickrOAuthService: NSObject {
    
    private let storageService: LocalStorageServiceProtocol
    
    init(storageService: LocalStorageServiceProtocol) {
        self.storageService = storageService
    }
    
    // MARK: - Authorization State
    
    private enum AuthorizationState: CustomStringConvertible {
        case requestTokenRequested
        case authorizeRequested(handler: (URL) -> Void)
        case accessTokenRequested
        case successfullyAuthenticated
        
        var description: String {
            switch self {
            case .requestTokenRequested:
                return "requestTokenRequested"
            case .authorizeRequested(handler: _):
                return "authorizeRequested"
            case .accessTokenRequested:
                return "accessTokenRequested"
            case .successfullyAuthenticated:
                return "successfullyAuthenticated"
            }
        }
    }
    
    private var isAutherized: AuthorizationState? {
        didSet {
            do {
                if case .successfullyAuthenticated = isAutherized {
                    try storageService.set(for: true, with: UserDefaults.Keys.isAuthorized.rawValue)
                } else {
                    try storageService.set(for: false, with: UserDefaults.Keys.isAuthorized.rawValue)
                }
            } catch(let storageError) {
                print(storageError)
            }
        }
    }
    
    // MARK: - Additional Methods
    
    func isAuthorized() -> Bool {
        switch isAutherized {
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
    struct AccessTokenOAuth: Codable {
        let token: String
        let secretToken: String
        let userNSID: String
        let username: String
    }
    
    // MARK: - Public Methods API OAuth1.0
    
    func flickrLogin(presenter: UIViewController, completion: @escaping (Result<AccessTokenOAuth, Error>) -> Void) {
        guard isAutherized == nil else {
            completion(.failure(ErrorMessage.error("User is already logged in.")))
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
                                self?.isAutherized = .successfullyAuthenticated
                                DispatchQueue.main.async {
                                    completion(.success(accessToken))
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func flickrLogout() {
        isAutherized = nil
    }
    
    // MARK: - Steps OAuth1.0 Methods
    
    // Step #1: Getting Request Token
    private func getRequestToken(completion: @escaping (Result<RequestTokenOAuth, Error>) -> Void) {
        isAutherized = .requestTokenRequested
        
        let parameters: [String: String] = [
            "oauth_callback": FlickrConstant.Callback.schemeURL.rawValue
        ]
        
        requestOAuth(params: parameters, path: .requestTokenOAuth, method: .POST) { result in
            switch result {
            case .success(let data):
                // Convert Data into String (Response: oauth_token=XXXX&oauth_token_secret=YYYY&oauth_callback_confirmed=true)
                guard let dataString = String(data: data, encoding: .utf8) else { return }
                
                // Convert response data to parameters
                let attributes = self.convertStringToParameters(dataString)
                guard let token = attributes["oauth_token"], let secretToken = attributes["oauth_token_secret"] else {
                    self.isAutherized = nil
                    completion(.failure(ErrorMessage.error("Request token was not found.")))
                    return
                }
                
                completion(.success(RequestTokenOAuth(token: token, secretToken: secretToken)))
            case .failure(let error):
                self.isAutherized = nil
                completion(.failure(error))
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
    private func requestAuthorize(with token: String, presenter: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        // Build website confirmation link for 'Safari'
        let urlString = "\(FlickrConstant.URL.base.rawValue)/services/oauth/authorize?oauth_token=\(token)&perms=delete" //write
        guard let websiteConfirmationURL = URL(string: urlString) else { return }
        
        // Initialization 'Safari' object
        let safari = SFSafariViewController(url: websiteConfirmationURL)
        safari.delegate = self
        // Return 'ArgumentsAccessToken' after callback URL
        isAutherized = .authorizeRequested() { [weak self] url in
            // Dismiss the 'Safari' ViewController
            safari.dismiss(animated: true, completion: nil)
            
            guard let query = url.query else {
                completion(.failure(ErrorMessage.error("Parameters were not found after confirmation on the website.")))
                return
            }
            
            // Transformation: oauth-flickr://?oauth_token=XXXX&oauth_verifier=ZZZZ => ["oauth_token": "XXXX", "oauth_verifier": "YYYY"]
            let parameters = self?.convertStringToParameters(query)
            
            guard let verifier = parameters?["oauth_verifier"] else {
                completion(.failure(ErrorMessage.error("Parameters were not found after confirmation on the website.")))
                return
            }
            
            print("'verifier' -> Status: Complete")
            completion(.success(verifier))
        }
        
        // Async preview after receiving the link
        DispatchQueue.main.async {
            presenter.present(safari, animated: true, completion: nil)
        }
    }
    
    // Catch URL callback after confirmed authorization (Step #2: Website Confirmation)
    func handleURL(_ url: URL) {
        guard case let .authorizeRequested(handler) = isAutherized else {
            self.isAutherized = nil
            fatalError("Invalid authorization state.")
        }
        
        handler(url)
    }
    
    // Step #3: Getting Access Token
    private func getAccessToken(arguments: ArgumentsAccessToken, completion: @escaping (Result<AccessTokenOAuth, Error>) -> Void) {
        // Change authorization state
        isAutherized = .accessTokenRequested
        
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
                    self.isAutherized = nil
                    completion(.failure(ErrorMessage.error("Access token was not found.")))
                    return
                }
                
                completion(.success(AccessTokenOAuth(token: token, secretToken: secretToken, userNSID: userNSID, username: username)))
            case .failure(let error):
                self.isAutherized = nil
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Request Configuration Methods
    
    private func requestOAuth(secretToken: String? = nil, params extraParameters: [String: String], path: FlickrConstant.OAuthPath, method: HTTPMethod, completion: @escaping (Result<Data, Error>) -> Void) {
        // Build base URL with path as parameter
        let urlString = FlickrConstant.URL.base.rawValue + path.rawValue
        
        // Create URL using endpoint
        guard let url = URL(string: urlString) else { return }
        
        // Initialize and configure URL request
        var urlRequest = URLRequest(url: url)
        
        // Set HTTP method to request using HttpMethodType with uppercase letters
        var parameters: [String: String] = [
            "oauth_consumer_key": FlickrConstant.Key.consumerKey.rawValue,
            // Value 'nonce' can be any 32-bit string made up of random ASCII values
            "oauth_nonce": UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
            "oauth_version": "1.0"
        ]
        
        
        
        // Add to parameters extra values
        parameters = parameters.merging(extraParameters) { (current, _) in current }
        
        // Methods to prepare API requests
        let signatureBuilder = SignatureBuilder(consumerSecretKey: FlickrConstant.Key.consumerSecretKey.rawValue, accessSecretToken: secretToken)
        let signature = signatureBuilder.buildSignature(method: method.rawValue, endpoint: urlString, parameters: parameters)
        parameters["oauth_signature"] = signature
        
        urlRequest.httpMethod = method.rawValue
        
        // Set parameters to HTTP body of URL request
        let header = "OAuth \(signatureBuilder.convertParametersToString(parameters, separator: ", "))"
        urlRequest.setValue(header, forHTTPHeaderField: "Authorization")
        
        // URL configuration
        let config = URLSessionConfiguration.default
        
        // Request creation
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ErrorMessage.error("HTTP response is empty.")))
                return
            }
            
            guard let data = data else {
                completion(.failure(ErrorMessage.error("Data response is empty.")))
                return
            }
            
            print(String(data: data, encoding: .utf8)!)
            
            switch httpResponse.statusCode {
            case ..<200:
                completion(.failure(ErrorMessage.error("Informational message error (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            case ..<300:
                print("\(path == .requestTokenOAuth ? "'request_token'" : "'access_token'") -> Status: \(httpResponse.statusCode) OK")
                completion(.success(data))
            case ..<400:
                completion(.failure(ErrorMessage.error("Redirection message (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            case ..<500:
                completion(.failure(ErrorMessage.error("Client request error (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            case ..<600:
                completion(.failure(ErrorMessage.error("Internal server error (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            default:
                completion(.failure(ErrorMessage.error("Unknown status code (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            }
        }
        
        // Start request process
        task.resume()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

// MARK: - SFSafariViewControllerDelegate

extension FlickrOAuthService: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.isAutherized = nil
    }
    
}
