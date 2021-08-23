//
//  NetworkService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.08.2021.
//

import Foundation

// MARK: - API Access Structure

struct AccessTokenAPI {
    let token: String
    let secret: String
}

// MARK: - Network Layer (REST)

class NetworkService: RequestPreparation {
    
    // Token to get access to 'Flickr API'
    private let access: AccessTokenAPI
    
    // Without access token 'NetworkService' do not work
    init(withAccess accessToken: AccessTokenAPI) {
        self.access = accessToken
    }
    
    // MARK: - Special Methods
    
    func testLoginRequest() {
        let parameters: [String: String] = [
            "nojsoncallback": "1",
            "format": "json",
            "oauth_token": access.token,
            "method": "flickr.test.login"
        ]
        
        request(params: parameters, path: .requestREST, method: .GET) { result in
            switch result {
            case .success(let data):
                do {
                    guard let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
                    print("Response: \(response)")
                } catch(let error) {
                    print("Data couldn't be parsed: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Get 'flickr.test.login' error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Foundation Methods
    
    private func request(params extraParameters: [String: String], path: HttpEndpoint.PathType, method: HttpMethodType, complition: @escaping (Result<Data, Error>) -> Void) {
        // Build base URL with path as parameter
        let urlString = HttpEndpoint.baseDomain.rawValue + path.rawValue
        
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
        parameters["oauth_signature"] = createRequestSignature(httpMethod: method.rawValue, url: urlString, parameters: parameters, secretToken: access.secret)
        
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
//            guard let httpResponse = response as? HTTPURLResponse else {
//                complition(.failure(.responseIsEmpty))
//                return
//            }
//            
//            guard let data = data else {
//                complition(.failure(.dataIsEmpty))
//                return
//            }
//            
//            switch httpResponse.statusCode {
//            case 200..<300:
//                print("Status Code: \(httpResponse.statusCode)\nMessage: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
//                complition(.success(data))
//            case ..<500:
//                print("Status Code: \(httpResponse.statusCode)\nMessage: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
//                complition(.failure(.invalidSignature))
//            case ..<600:
//                print("Status Code: \(httpResponse.statusCode)\nMessage: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
//                complition(.failure(.serverInternalError))
//            default:
//                print("Unknown status code!")
//                complition(.failure(.unexpected(code: httpResponse.statusCode)))
//            }
        }
        
        // Start request process
        task.resume()
    }

}
