//
//  NetworkService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import Foundation
import CommonCrypto
import UIKit

// MARK: - HTTP method types
enum HttpMethodType: String {
    case get
    case post
    case delete
    case put
    case patch
}

// MARK: - Network Layer
class NetworkService {
    
    // MARK: - Request prepare methods
    
    private func encodedUrl(_ value: String?) -> String? {
        var charset: CharacterSet = .urlQueryAllowed
        charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        return value?.addingPercentEncoding(withAllowedCharacters: charset)
    }
    
    private func prepareSignatureKey(consumerSecretKey: String, tokenSecretOAuth: String?) -> String {
        guard let tokenSecretOAuth = encodedUrl(tokenSecretOAuth) else { return encodedUrl(consumerSecretKey)! + "&" }
        return encodedUrl(consumerSecretKey)! + "&" + tokenSecretOAuth
    }
    
    private func prepareSignatureParameterString(parameters: [String: Any]) -> String {
        var result: [String] = []
        for parameter in parameters {
            let key = encodedUrl(parameter.key)!
            let val = encodedUrl("\(parameter.value)")!
            result.append("\(String(describing: key))=\(String(describing: val))")
        }
        return result.sorted().joined(separator: "&")
    }
    
    private func prepareSignatureBaseString(httpMethod: String, url: String, parameters: [String: Any]) -> String {
        let parameterString = prepareSignatureParameterString(parameters: parameters)
        return httpMethod + "&" + encodedUrl(url)! + "&" + encodedUrl(parameterString)!
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
            let key = encodedUrl(parameter.key)!
            let val = encodedUrl("\(parameter.value)")!
            parts.append("\(String(describing: key))=\"\(String(describing: val))\"")
        }
        let header = "OAuth " + parts.sorted().joined(separator: ", ")

        return header
    }
    
    
    // MARK: - Base function where process request configuration
    private func requestOAuth(args: (requestToken: String, requestSecretToken: String, verifierOAuth: String)? = nil, path: HttpEndpoint.PathType, method: HttpMethodType, complition: @escaping (Result<Data, Error>) -> Void) {
        // Build base URL with path as parameter
        let urlString = HttpEndpoint.InternetProtocolType.https.rawValue + HttpEndpoint.HostType.hostAPI.rawValue + path.rawValue
        
        // Create URL using endpoint
        guard let url = URL(string: urlString) else { return }
        
        // Initialize and configure URL request
        var urlRequest = URLRequest(url: url)
        
        // Set HTTP method to request using HttpMethodType with uppercase letters
        urlRequest.httpMethod = method.rawValue.uppercased()
        
        // Generate valid parameetrs
        let callback = "oauth-flickr://"//://oauth-callback/flickr" //://oauth_callback"//(args != nil ? nil : FlickrAPI.urlScheme.rawValue + "://success")
        let tokenOAuth = args?.requestToken
        let verifierOAuth = args?.verifierOAuth
        let tokenSecretOAuth = (args != nil ? args?.requestSecretToken : nil)
        
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
    
    struct RequestAccessTokenInput {
        let consumerKey: String
        let consumerSecret: String
        let requestToken: String // = RequestOAuthTokenResponse.oauthToken
        let requestTokenSecret: String // = RequestOAuthTokenResponse.oauthTokenSecret
        let oauthVerifier: String
    }
    struct RequestAccessTokenResponse {
        let accessToken: String
        let accessTokenSecret: String
        let userId: String
        let screenName: String
    }
    struct RequestOAuthTokenInput {
        let consumerKey: String
        let consumerSecret: String
        let callbackScheme: String
    }
    
    struct RequestOAuthTokenResponse {
        let oauthToken: String
        let oauthTokenSecret: String
        let oauthCallbackConfirmed: String
    }

    func requestTokenResponseParsing(_ response: String) -> Dictionary<String, String> {
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
    
    private struct RequestTokenOAuth {
        let token: String
        let secretToken: String
        let callbackConfirmed: String
    }
    
    // MARK: - Special cases of requests
    private func getOAuthRequestToken(complition: @escaping (Result<URL, Never>) -> Void) {
        requestOAuth(path: .requestTokenOAuth, method: .post) { result in
            switch result {
            case .success(let data):
                // Convert Data into String (Response: oauth_token=XXXX&oauth_token_secret=YYYY&oauth_callback_confirmed=true)
                guard let dataString = String(data: data, encoding: .utf8) else { return }
                print(dataString + "\n")
                let attributes = self.requestTokenResponseParsing(dataString)
                let requestToken = RequestTokenOAuth(token: attributes["oauth_token"] ?? "", secretToken: attributes["oauth_token_secret"] ?? "", callbackConfirmed: attributes["oauth_callback_confirmed"] ?? "")
                self.reqToken = requestToken
                
                // Start Step 2: User Flickr Login
                let urlString = "\(HttpEndpoint.InternetProtocolType.https.rawValue + HttpEndpoint.HostType.hostAPI.rawValue + HttpEndpoint.PathType.authorizeOAuth.rawValue)?oauth_token=\(requestToken.token)&perms=write"
                guard let urlOAuth = URL(string: urlString) else { return }
                NotificationCenter.default.addObserver(self, selector: #selector(self.safariLogin(_:)), name: Notification.Name("CallbackNotification"), object: nil)

                complition(.success(urlOAuth))
            case .failure(let error):
                print("Get 'request_token' error: \(error.localizedDescription)")
            }
        }
    }
    
    var verifier: String?
    private var reqToken: RequestTokenOAuth?
    
    @objc
    func safariLogin(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CallbackNotification"), object: nil)
        
        // Callback data after authorize
        guard let url = notification.object as? URL else { return }

        // URL parsing
        let parameters = requestTokenResponseParsing(url.query!)
        guard let verifier = parameters["oauth_verifier"] else { return }
        self.verifier = verifier
        
        getOAuthAccessToken(args: reqToken!)
                        /*
                         url => flickrsdk://success?oauth_token=XXXX&oauth_verifier=ZZZZ
                         url.query => oauth_token=XXXX&oauth_verifier=ZZZZ
                         url.query?.urlQueryStringParameters => ["oauth_token": "XXXX", "oauth_verifier": "YYYY"]
                         */

    }
    
    private struct AccessTokenOAuth {
        let token: String
        let secretToken: String
        let userNSId: String
        let username: String
    }
    
    private func getOAuthAccessToken(args: RequestTokenOAuth) {
        requestOAuth(args: (requestToken: args.token, requestSecretToken: args.secretToken, verifierOAuth: self.verifier!), path: .accessTokenOAuth, method: .post) { result in
            switch result {
            case .success(let data):
                // Convert Data into String (Response: oauth_token=XXXX&oauth_token_secret=YYYY&user_nsid=CCC&username=NNN)
                guard let dataString = String(data: data, encoding: .utf8) else { return }
                print(dataString)
                let attributes = self.requestTokenResponseParsing(dataString)
                let accessToken = AccessTokenOAuth(token: attributes["oauth_token"] ?? "", secretToken: attributes["oauth_token_secret"] ?? "", userNSId: attributes["user_nsid"] ?? "", username: attributes["username"] ?? "")
            case .failure(let error):
                print("Get 'access_token' error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - API OAuth
    func accountOAuth(comp: @escaping (Result<URL, Never>) -> Void) {
        getOAuthRequestToken { result in
            switch result {
            case .success(let url):
                comp(.success(url))
            }
        }
    }
    
    func accountSignOut() {
        
    }
    
}
