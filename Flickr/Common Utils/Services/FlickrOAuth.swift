//
//  NetworkService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit
import SafariServices
import CommonCrypto

// MARK: - Network OAuth1.0 Layer (Flickr API)

class FlickrOAuth: NSObject {
    
    // Singleton
    static let shared = FlickrOAuth()
    
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
    
    private func requestOAuth(args: RequestArgumentsOAuth? = nil, path: HttpEndpoint.PathType, method: HttpMethodType, complition: @escaping (Result<Data, FlickrOAuthError>) -> Void) {
        // Build base URL with path as parameter
        let urlString = HttpEndpoint.InternetProtocolType.https.rawValue + HttpEndpoint.HostType.hostAPI.rawValue + path.rawValue
        
        // Create URL using endpoint
        guard let url = URL(string: urlString) else { return }
        
        // Initialize and configure URL request
        var urlRequest = URLRequest(url: url)
        
        // Set HTTP method to request using HttpMethodType with uppercase letters
        urlRequest.httpMethod = method.rawValue
        
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
        parameters["oauth_signature"] = createSignatureOAuth(httpMethod: method.rawValue, url: urlString, parameters: parameters, tokenSecretOAuth: tokenSecretOAuth)
        
        // Set parameters to HTTP body of URL request
        let header = "OAuth \(convertParametersToString(parameters, separator: ", "))"
        urlRequest.setValue(header, forHTTPHeaderField: "Authorization")
        //urlRequest.setValue(encodeAuthorizationHeader(parameters: parameters), forHTTPHeaderField: "Authorization")
        
        // URL configuration
        let config = URLSessionConfiguration.default
        
        // Request creation
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                complition(.failure(.responseIsEmpty))
                return
            }
            
            guard let data = data else {
                complition(.failure(.dataIsEmpty))
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                print("Status Code: \(httpResponse.statusCode)\nMessage: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                complition(.success(data))
            case ..<500:
                print("Status Code: \(httpResponse.statusCode)\nMessage: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                complition(.failure(.invalidSignature))
            case ..<600:
                print("Status Code: \(httpResponse.statusCode)\nMessage: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                complition(.failure(.serverInternalError))
            default:
                print("Unknown status code!")
                complition(.failure(.unexpected(code: httpResponse.statusCode)))
            }
        }
        
        // Start request process
        task.resume()
    }
    
    // MARK: - Special Requests Cases
    
    private func getOAuthRequestToken(complition: @escaping (Result<URL, Error>) -> Void) {
        requestOAuth(path: .requestTokenOAuth, method: .POST) { result in
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
                
                complition(.success(urlOAuth))
                
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    private func getOAuthAccessToken(args: RequestArgumentsOAuth) {
        requestOAuth(args: args, path: .accessTokenOAuth, method: .POST) { result in
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
    
    func handleURL(_ url: URL) {
        // Transformation: url => oauth-flickr://?oauth_token=XXXX&oauth_verifier=ZZZZ => ["oauth_token": "XXXX", "oauth_verifier": "YYYY"]
        let parameters = requestTokenResponseParsing(url.query ?? "")
        guard let verifier = parameters["oauth_verifier"] else { return }
        args?.verifier = verifier
        
        // Triggered function to close 'Safari'
        closeSafari()
        
        guard let args = args else { return }
        
        // Step #3: Getting 'access_token'
        getOAuthAccessToken(args: args)
    }
    
    // MARK: - Public Methods API OAuth1.0
    
    func flickrLogin(presenter: UIViewController) {
        // Step #1: Getting 'request_token'
        getOAuthRequestToken() { result in
            switch result {
            case .success(let url):
                // Step #2: Getting user website confirmation
                self.openSafari(from: presenter, for: url)
            case .failure(let error):
                print("Get 'request_token' error: \(error.localizedDescription)")
            }
        }
    }
    
    func flickrLogout() {
        // Sign out from 'Flickr' account
    }
    
    // MARK: - Safari Methods
    
    private var safari: SFSafariViewController?
    
    // Show preview web page from current ViewController in 'Safari'
    private func openSafari(from viewController: UIViewController, for url: URL) {
        // Initialization 'Safari' object
        safari = .init(url: url)
        
        // Async preview after receiving the link
        DispatchQueue.main.async {
            guard let safari = self.safari else { return }
            viewController.present(safari, animated: true, completion: nil)
        }
    }
    
    // Close 'Safari' web page preview
    private func closeSafari() {
        // Dismiss the 'Safari' ViewController
        self.safari?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Prepare Methods
    
    // HMAC-SHA1 method to create signature
    private func hashMessageAuthenticationCodeSHA1(signingKey: String, baseSignature: String) -> String {
        // HMAC-SHA1 hashing algorithm returned as a base64 encoded string
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.count, baseSignature, baseSignature.count, &digest)
        return Data(digest).base64EncodedString()
    }
    
    // Method uses for prepare headers and signature parameters
    private func convertParametersToString(_ parameters: [String: Any], separator: String) -> String {
        var result: [String] = []
        for parameter in parameters {
            let key = parameter.key
            let value = encodedUrl("\(parameter.value)")
            result.append("\(key)=\(value)")
        }
        return result.sorted().joined(separator: separator)
    }
    
    // Method uses for creating signature to get 'authorize' request
    private func createSignatureOAuth(httpMethod: String, url: String, parameters: [String: Any], consumerSecretKey: String = FlickrAPI.secretKey.rawValue, tokenSecretOAuth: String? = nil) -> String {
        // Initialization 'Signing Key'
        let signingKey = "\(consumerSecretKey)&\(tokenSecretOAuth ?? "")"
        
        // Initialization 'Signing Base'
        let stringParameters = convertParametersToString(parameters, separator: "&")
        let baseSignature = "\(httpMethod)&\(encodedUrl(url))&\(encodedUrl(stringParameters))"
        
        // Build 'Signature' using HMAC-SHA1
        let signature = hashMessageAuthenticationCodeSHA1(signingKey: signingKey, baseSignature: baseSignature)
        
        return signature
    }
    
}

// MARK: - Refactoring
/*
 1. В структуре RequestArgumentsOAuth оставить опциональным только Verifier
 2. Передавать UIViewController в функцию авторизации
 3. Заменить явное указание типа Dictionary<String, String> через литеральный вариант [String: String]
 4. В GIT удалил файл с приватными данными FlickrAPI
 5. Сделать FlickrOAuth синглтоном, чтобы вызывать функцию handleURL(_ url: URL) для прокидывания callback ссылки из SceneDelegate
 6. Браузер открывать/закрывать в FlickrOAuth
 7. Добавлен вывод статус кода из запроса на сервер
 8. Добавлен вызов ошибок
 9. Объеденены методы подготови заголовка 'encodeAuthorizationHeader' и параметров подписи 'prepareSignatureParameterString' в один метод
 10. Объеденены методы подготовки ключей подписи, вся реализация теперь находиться в методе createSignatureOAuth
 11. В перечислении HTTP кейсы теперь по умолчанию uppercased()
 */
