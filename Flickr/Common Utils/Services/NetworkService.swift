//
//  NetworkService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import Foundation
import CommonCrypto


// MARK: - HTTP method types
enum HttpMethodType: String {
    case get
    case post
    case delete
    case put
    case patch
}

// MARK: - Network Layer
struct NetworkService {
    
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
        print("Signing key: \(signingKey)")
        
        // Initialization 'Signing Base'
        let signatureBase = prepareSignatureBaseString(httpMethod: httpMethod, url: url, parameters: parameters)
        print("Signature Base: \(signatureBase)")
        
        // Build 'Signature' using HMAC-SHA1
        let signature = hashMessageAuthenticationCodeSHA1(signingKey: signingKey, baseSignature: signatureBase)
        print("Signature: \(signature)")
        
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
        print(header)
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
        let callback = FlickrAPI.urlScheme.rawValue + "://success"
        
        let parametersAccessToken: [String: Any] = [
            "oauth_token" : args?.requestToken,
            "oauth_verifier" : args?.verifierOAuth,
        ]
        
        let parametersOAuth: [String: Any] = [
            "oauth_callback" : callback
        ]
        
        var parameters: [String: Any] = [
            "oauth_callback" : callback,
            "oauth_consumer_key" : FlickrAPI.consumerKey.rawValue,
            // Value 'nonce' can be any 32-bit string made up of random ASCII values
            "oauth_nonce" : UUID().uuidString,
            "oauth_signature_method" : "HMAC-SHA1",
            "oauth_timestamp" : String(Int(Date().timeIntervalSince1970)),
            "oauth_version" : "1.0"
        ]
        
        //let additionalParameters = (args != nil ? parametersAccessToken : parametersOAuth)
        
//        additionalParameters.forEach { (key, value) in
//            parameters[key] = value
//        }
//
        // Build the OAuth signature from parameters
        parameters["oauth_signature"] = signatureOAuth(httpMethod: method.rawValue.uppercased(), url: urlString, parameters: parameters, tokenSecretOAuth: nil)//args != nil ? args?.requestSecretToken : nil)
                
        // Set parameters to HTTP body of URL request
        urlRequest.setValue(encodeAuthorizationHeader(parameters: parameters), forHTTPHeaderField: "Authorization")
        //urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
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
    
    // MARK: - Special cases of requests
    func getAccessToketOAuth() {
        requestOAuth(path: .accessTokenOAuth, method: .post) { result in
            switch result {
            case .success(let data):
                guard let dataString = String(data: data, encoding: .utf8) else { return }
                print(dataString)
            case .failure(let error):
                print("Get 'access_token' error: \(error.localizedDescription)")
            }
        }
    }
    
    func getOAuthToken() {
        requestOAuth(path: .requestTokenOAuth, method: .post) { result in
            switch result {
            case .success(let data):
                do {
                    guard let dataString = String(data: data, encoding: .utf8) else { return }
                    print(dataString)
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Get 'access_token' error: \(error.localizedDescription)")
            }
        }
    }
}
