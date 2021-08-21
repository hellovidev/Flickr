//
//  NetworkService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit
import CommonCrypto

// MARK: - Network Layer (Flickr API)
class FlickrOAuth {
    
    private var args: RequestArgumentsOAuth?
    
    // MARK: - Storage For Responses
    
    // Structure to save request token response
    private struct RequestTokenOAuth {
        let token: String
        let secretToken: String
        let callbackConfirmed: String
    }
    
    // Structure to build request arguments
    private struct RequestArgumentsOAuth {
        var token: String
        var secretToken: String
        var verifier: String?
    }
    
    // Structure to save access token response
    private struct AccessTokenOAuth {
        let token: String
        let secretToken: String
        let userNSId: String
        let username: String
    }
    
    // MARK: - Request Prepare Methods
    
    private func encodedUrl(_ value: String) -> String {
        var charset: CharacterSet = .urlQueryAllowed
        charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        return value.addingPercentEncoding(withAllowedCharacters: charset)!
    }
    
    private func prepareSignatureKey(consumerSecretKey: String, tokenSecretOAuth: String?) -> String {
        guard let tokenSecretOAuth = tokenSecretOAuth else { return encodedUrl(consumerSecretKey) + "&" }
        return encodedUrl(consumerSecretKey) + "&" + encodedUrl(tokenSecretOAuth)
    }
    
    private func prepareSignatureParameterString(parameters: [String: Any]) -> String {
        var result: [String] = []
        for parameter in parameters {
            let key = encodedUrl(parameter.key)
            let val = encodedUrl("\(parameter.value)")
            result.append("\(key)=\(val)")
        }
        return result.sorted().joined(separator: "&")
    }
    
    private func prepareSignatureBaseString(httpMethod: String, url: String, parameters: [String: Any]) -> String {
        let parameterString = prepareSignatureParameterString(parameters: parameters)
        return httpMethod + "&" + encodedUrl(url) + "&" + encodedUrl(parameterString)
    }
    
    private func hashMessageAuthenticationCodeSHA1(signingKey: String, baseSignature: String) -> String {
        // HMAC-SHA1 hashing algorithm returned as a base64 encoded string
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.count, baseSignature, baseSignature.count, &digest)
        return Data(digest).base64EncodedString()
    }
    
    private func signatureOAuth(httpMethod: String, url: String, parameters: [String: Any], consumerSecretKey: String = FlickrAPI.secretKey.rawValue, tokenSecretOAuth: String? = nil) -> String {
        // Initialization 'Signing Key'
        let signingKey = prepareSignatureKey(consumerSecretKey: consumerSecretKey, tokenSecretOAuth: tokenSecretOAuth)

        // Initialization 'Signing Base'
        let signatureBase = prepareSignatureBaseString(httpMethod: httpMethod, url: url, parameters: parameters)

        // Build 'Signature' using HMAC-SHA1
        let signature = hashMessageAuthenticationCodeSHA1(signingKey: signingKey, baseSignature: signatureBase)

        return signature
    }
    
    private func encodeAuthorizationHeader(parameters: [String: Any]) -> String {
        var parts: [String] = []
        for parameter in parameters {
            let key = encodedUrl(parameter.key)
            let val = encodedUrl("\(parameter.value)")
            parts.append("\(key)=\"\(val)\"")
        }
        let header = "OAuth " + parts.sorted().joined(separator: ", ")

        return header
    }
    
    private func requestTokenResponseParsing(_ response: String) -> [String: String] {
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
    
    // MARK: - Base Function Where Process Request Configuration
    
    private func requestOAuth(args: RequestArgumentsOAuth? = nil, path: HttpEndpoint.PathType, method: HttpMethodType, complition: @escaping (Result<Data, Error>) -> Void) {
        // Build base URL with path as parameter
        let urlString = HttpEndpoint.InternetProtocolType.https.rawValue + HttpEndpoint.HostType.hostAPI.rawValue + path.rawValue
        
        // Create URL using endpoint
        guard let url = URL(string: urlString) else { return }
        
        // Initialize and configure URL request
        var urlRequest = URLRequest(url: url)
        
        // Set HTTP method to request using HttpMethodType with uppercase letters
        urlRequest.httpMethod = method.rawValue.uppercased()
        
        // Generate valid parameetrs
        let callback = (args != nil ? nil : FlickrAPI.urlScheme.rawValue)
        let tokenOAuth = args?.token
        let verifierOAuth = args?.verifier
        let tokenSecretOAuth = (args != nil ? args?.secretToken : nil)
        
        var parameters: [String: Any] = [
            "oauth_callback" : callback ?? "",
            "oauth_token" : tokenOAuth ?? "",
            "oauth_verifier" : verifierOAuth ?? "",
            "oauth_consumer_key" : FlickrAPI.consumerKey.rawValue,
            // Value 'nonce' can be any 32-bit string made up of random ASCII values
            "oauth_nonce" : UUID().uuidString,
            "oauth_signature_method" : "HMAC-SHA1",
            "oauth_timestamp" : String(Int(Date().timeIntervalSince1970)),
            "oauth_version" : "1.0"
        ]
        
        // Build the OAuth signature from parameters
        parameters["oauth_signature"] = signatureOAuth(httpMethod: method.rawValue.uppercased(), url: urlString, parameters: parameters, tokenSecretOAuth: tokenSecretOAuth)
        
        // Set parameters to HTTP body of URL request
        urlRequest.setValue(encodeAuthorizationHeader(parameters: parameters), forHTTPHeaderField: "Authorization")
        
        // URL configuration
        let config = URLSessionConfiguration.default
        //config.allowsCellularAccess = true
        
        // Request creation
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                complition(.success(data))
            } else {
                complition(.failure(error!))
            }
        }
        
        // Start request process
        task.resume()
    }
    
    // MARK: - Special Requests Cases
    
    private func getOAuthRequestToken() {
        requestOAuth(path: .requestTokenOAuth, method: .post) { result in
            switch result {
            case .success(let data):
                // Convert Data into String (Response: oauth_token=XXXX&oauth_token_secret=YYYY&oauth_callback_confirmed=true)
                guard let dataString = String(data: data, encoding: .utf8) else { return }

                // Parse data response
                let attributes = self.requestTokenResponseParsing(dataString)
                let requestToken = RequestTokenOAuth(token: attributes["oauth_token"] ?? "", secretToken: attributes["oauth_token_secret"] ?? "", callbackConfirmed: attributes["oauth_callback_confirmed"] ?? "")
                
                // Build arguments for feature access token request
                self.args = .init(token: requestToken.token, secretToken: requestToken.secretToken, verifier: nil)
                
                // Start User Flickr Login using 'Safari' (Step №2)
                let urlString = "\(HttpEndpoint.InternetProtocolType.https.rawValue + HttpEndpoint.HostType.hostAPI.rawValue + HttpEndpoint.PathType.authorizeOAuth.rawValue)?oauth_token=\(requestToken.token)&perms=write"
                guard let urlOAuth = URL(string: urlString) else { return }
                
                // Subscribe to callback data (verifier) after website confirmation
                NotificationCenter.default.addObserver(self, selector: #selector(self.callbackSafariAuthorization(_:)), name: Notification.Name(Constant.NotificationName.callbackAuthorization.rawValue), object: nil)
                
                // Trigered function to open 'Safari'
                NotificationCenter.default.post(name: Notification.Name(Constant.NotificationName.websiteСonfirmationRequired.rawValue), object: urlOAuth)
            case .failure(let error):
                print("Get 'request_token' error: \(error.localizedDescription)")
            }
        }
    }
    
    private func getOAuthAccessToken(args: RequestArgumentsOAuth) {
        requestOAuth(args: args, path: .accessTokenOAuth, method: .post) { result in
            switch result {
            case .success(let data):
                // Convert Data into String (Response: oauth_token=XXXX&oauth_token_secret=YYYY&user_nsid=CCC&username=NNN)
                guard let dataString = String(data: data, encoding: .utf8) else { return }
                
                // Parse data response
                let attributes = self.requestTokenResponseParsing(dataString)
                let accessToken = AccessTokenOAuth(token: attributes["oauth_token"] ?? "", secretToken: attributes["oauth_token_secret"] ?? "", userNSId: attributes["user_nsid"] ?? "", username: attributes["username"] ?? "")
                
                // Change authentication state as like (self.authenticationState = .successfullyAuthenticated)
                print("Authorization result: \(accessToken)")
            case .failure(let error):
                print("Get 'access_token' error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc
    private func callbackSafariAuthorization(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constant.NotificationName.callbackAuthorization.rawValue), object: nil)
        
        // Callback data after authorize
        guard let url = notification.object as? URL else { return }
        
        // Transformation: url => oauth-flickr://?oauth_token=XXXX&oauth_verifier=ZZZZ => ["oauth_token": "XXXX", "oauth_verifier": "YYYY"]
        let parameters = requestTokenResponseParsing(url.query ?? "")
        guard let verifier = parameters["oauth_verifier"] else { return }
        args?.verifier = verifier
        
        // Triggered function to close 'Safari'
        NotificationCenter.default.post(name: Notification.Name(Constant.NotificationName.triggerBrowserTargetComplete.rawValue), object: nil)
        
        guard let args = args else { return }
        getOAuthAccessToken(args: args)
    }
    
    // MARK: - Public Methods API OAuth1.0
    
    func accountOAuth(presenter: UIViewController) {
        getOAuthRequestToken()
    }
    
    func accountSignOut() {
        // Sign out from 'Flickr' account
    }
    
}

// MARK: - Refactoring
/*
 1. В структуре RequestArgumentsOAuth оставить опциональным только Verifier
 2. Передавать UIViewController в функцию авторизации
 3. Заменить явное указание типа Dictionary<String, String> через литеральный вариант [String: String]
 */
