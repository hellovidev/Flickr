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
    
    // MARK: - Structs For Responses
    
    // Structure to save request token response
    struct RequestTokenOAuth {
        let token: String
        let secretToken: String
    }
    
    // Structure to build request arguments
    struct RequestArgumentsOAuth {
        var token: String
        var secretToken: String
        var verifier: String
    }
    
    // Structure to save access token response
    struct AccessTokenOAuth {
        let token: String
        let secretToken: String
        let userNSId: String
        let username: String
    }
    
    // MARK: - Public Methods API OAuth1.0
    
    func flickrLogin(presenter: UIViewController) {
        // Step #1: Getting 'request_token'
        getRequestToken() { result in
            switch result {
            case .success(let token):
                // Save secret token for feature access token request
                self.secretToken = token.secretToken
                
                // Build website confirmation link for 'Safari', prepare to 'Step #2: Website Confirmation'
                let urlString = "https://www.flickr.com/services/oauth/authorize?oauth_token=\(token.token)&perms=write"
                guard let websiteConfirmationURL = URL(string: urlString) else { return }
                
                // Step #2: Getting user website confirmation
                self.openSafari(from: presenter, for: websiteConfirmationURL)
            case .failure(let error):
                print("Get 'request_token' error: \(error.localizedDescription)")
            }
        }
    }
    
    func flickrLogout() {
        // Sign out from 'Flickr' account
    }
    
    // Test login request with JSON response
    func getCurrenUser(access token: AccessTokenOAuth) {
        let parameters: [String: String] = ["nojsoncallback": "1", "format": "json", "oauth_token": token.token, "method": "flickr.test.login" ]
        
        request(secretToken: token.secretToken, params: parameters, path: HttpEndpoint.PathType.authenticatedRequest, method: .GET) { result in
            switch result {
            case .success(let data):
                do {
                    guard let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
                    print("Response: \(response)")
                } catch(let error) {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print("Get 'flickr.test.login' error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Base Request Configuration Methods
    
    // Base OAuth method
    private func requestOAuth(secretToken: String? = nil, params extraParameters: [String: String], path: HttpEndpoint.PathType, method: HttpMethodType, complition: @escaping (Result<Data, FlickrOAuthError>) -> Void) {
        // Build base URL with path as parameter
        let urlString = "https://www.flickr.com\(path.rawValue)"
        
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
        parameters["oauth_signature"] = createSignatureOAuth(httpMethod: method.rawValue, url: urlString, parameters: parameters, tokenSecretOAuth: secretToken)
        
        // Set parameters to HTTP body of URL request
        let header = "OAuth \(convertParametersToString(parameters, separator: ", "))"
        urlRequest.setValue(header, forHTTPHeaderField: "Authorization")
        
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
    
    // Base regular request method
    private func request(secretToken: String, params extraParameters: [String: String], path: HttpEndpoint.PathType, method: HttpMethodType, complition: @escaping (Result<Data, FlickrOAuthError>) -> Void) {
        // Build base URL with path as parameter
        let urlString = "https://www.flickr.com\(path.rawValue)"
        
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
        parameters["oauth_signature"] = createSignatureOAuth(httpMethod: method.rawValue, url: urlString, parameters: parameters, tokenSecretOAuth: secretToken)
        
        // Set parameters to request
        var components = URLComponents(string: urlString)
        components?.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        // Initialize and configure URL request
        guard let url = components?.url else { return }
        var urlRequest = URLRequest(url: url)
        
        // Set HTTP method to request using HttpMethodType with uppercase letters
        urlRequest.httpMethod = method.rawValue
        
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
    
    // MARK: - OAuth1.0 Steps Methods
    
    // Uses to save request secret token
    private var secretToken: String?
    
    // Catch URL callback after confirmed authorization (Step #2: Website Confirmation)
    func handleURL(_ url: URL) {
        // Transformation: oauth-flickr://?oauth_token=XXXX&oauth_verifier=ZZZZ => ["oauth_token": "XXXX", "oauth_verifier": "YYYY"]
        let parameters = convertStringToParameters(url.query ?? "")
        guard let verifier = parameters["oauth_verifier"], let token = parameters["oauth_token"], let secretToken = secretToken else {
            // App crash if one of the parameters is nil
            fatalError(FlickrOAuthError.dataCanNotBeParsed.localizedDescription)
        }
        let arguments = RequestArgumentsOAuth(token: token, secretToken: secretToken, verifier: verifier)
        
        // Triggered function to close 'Safari'
        closeSafari()
        
        // Step #3: Getting 'access_token'
        getAccessToken(arguments: arguments) { result in
            switch result {
            case .success(let token):
                print("Authorization result: \(token)")
                
                // Test to get JSON info
                self.getCurrenUser(access: token)
            // Change authentication state as like (self.authenticationState = .successfullyAuthenticated)
            case .failure(let error):
                print("Get 'access_token' error: \(error.localizedDescription)")
            }
        }
    }
    
    private func getRequestToken(complition: @escaping (Result<RequestTokenOAuth, FlickrOAuthError>) -> Void) {
        let parameters: [String: String] = ["oauth_callback": FlickrAPI.urlScheme.rawValue]
        
        requestOAuth(params: parameters, path: .requestTokenOAuth, method: .POST) { result in
            switch result {
            case .success(let data):
                // Convert Data into String (Response: oauth_token=XXXX&oauth_token_secret=YYYY&oauth_callback_confirmed=true)
                guard let dataString = String(data: data, encoding: .utf8) else { return }
                
                // Convert response data to parameters
                let attributes = self.convertStringToParameters(dataString)
                guard let token = attributes["oauth_token"], let secretToken = attributes["oauth_token_secret"] else {
                    complition(.failure(.dataCanNotBeParsed))
                    return
                }
                
                let requestToken = RequestTokenOAuth(token: token, secretToken: secretToken)
                complition(.success(requestToken))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    private func getAccessToken(arguments: RequestArgumentsOAuth, complition: @escaping (Result<AccessTokenOAuth, FlickrOAuthError>) -> Void) {
        let parameters: [String: String] = ["oauth_token": arguments.token, "oauth_verifier": arguments.verifier]
        
        requestOAuth(secretToken: arguments.secretToken, params: parameters, path: .accessTokenOAuth, method: .POST) { result in
            switch result {
            case .success(let data):
                // Convert Data into String (Response: oauth_token=XXXX&oauth_token_secret=YYYY&user_nsid=CCC&username=NNN)
                guard let dataString = String(data: data, encoding: .utf8) else { return }
                
                // Convert response data to parameters
                let attributes = self.convertStringToParameters(dataString)
                guard let token = attributes["oauth_token"], let secretToken = attributes["oauth_token_secret"], let userNSID = attributes["user_nsid"], let username = attributes["username"] else {
                    complition(.failure(.dataCanNotBeParsed))
                    return
                }
                
                let accessToken = AccessTokenOAuth(token: token, secretToken: secretToken, userNSId: userNSID, username: username)
                complition(.success(accessToken))
            case .failure(let error):
                complition(.failure(error))
            }
        }
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
    
    // Prepare string value to signature: 'https://www.flickr.com/services/oauth/request_token' => 'https%3A%2F%2Fwww.flickr.com%2Fservices%2Foauth%2Frequest_token'
    private func encodeString(_ value: String) -> String {
        var charset: CharacterSet = .urlQueryAllowed
        charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        return value.addingPercentEncoding(withAllowedCharacters: charset)!
    }
    
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
            let value = encodeString("\(parameter.value)")
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
        let baseSignature = "\(httpMethod)&\(encodeString(url))&\(encodeString(stringParameters))"
        
        // Build 'Signature' using HMAC-SHA1
        return hashMessageAuthenticationCodeSHA1(signingKey: signingKey, baseSignature: baseSignature)
    }
    
    // Uses to parse 'request_token' response
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
 12. Удалена глобальная переменная 'args'
 13. При отсутствии важных параметров будет вызываться ошибка, например если не получается сделать парсинг данных
 14. Не нужные параметры удалены
 15. Захардкодил ссылку на flickr.com
 16. Добавлены extraParameters в базовый метод запроса requestOAuth()
 17. Исправлена логика шагов авторизации в методе flickrLogin()
 18. Создан REST запрос сответом в виде JSON
 19. Разобраться с encodeString()
 
 *20. Получить данные авторизации через JSON - Отмена
 *21. Проблема с логикой вызова метода getAccessToken()
 */
