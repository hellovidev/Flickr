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
    let nsid: String
}

// MARK: - Network Layer (REST)

struct NetworkService {
    
    // Token to get access to 'Flickr API'
    let access: AccessTokenAPI
    
    // Without access token 'NetworkService' do not work
    init(withAccess accessToken: AccessTokenAPI) {
        self.access = accessToken
    }
    
    /*
     "{\"photos\":{\"page\":1,\"pages\":10,\"perpage\":100,\"total\":1000,\"photo\":[{\"id\":\"51404420132\",\"owner\":\"64642247@N00\",\"secret\":\"a4884d7257\",\"server\":\"65535\",\"farm\":66,\"title\":\"Sushi Toro Sapporo\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"51404420692\",\"owner\":\"96789674@N05\",\"secret\":\"a50bfed7f1\",\"server\":\"65535\",\"farm\":66,\"title\":\"Getting Godfather\'ed - the end!\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"51404421807\",\"owner\":\"193761298@N06\",\"secret\":\"9ffdf422ae\",\"server\":\"65535\",\"farm\":66,\"title\":\"Jasa Perhitungan Struktur \\u2013 STRUKTUR KOS WIJAYA KUSUMA\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"51404422282\",\"owner\":\"76690667@N08\",\"secret\":\"242b51dd73\",\"server\":\"65535\",\"farm\":66,\"title\":\"Waning gibbous Moon, 77.8%
     
     
     
     error always nil
     */
    
    // MARK: - Foundation Methods
    
    func request<Response>(
        params extraParameters: [String: String]? = nil,
        requestMethod: Constant.FlickrMethod,
        path: HttpEndpoint.PathType = .requestREST,
        method: HttpMethodType,
        parser: @escaping (Data) throws -> Response,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        // Build base URL with path as parameter
        let urlString = HttpEndpoint.baseDomain.rawValue + path.rawValue
        
        var parameters: [String: String] = [
            "nojsoncallback": "1",
            "format": "json",
            "oauth_token": access.token,
            "method": requestMethod.rawValue,
            "oauth_consumer_key": FlickrAPI.consumerKey.rawValue,
            // Value 'nonce' can be any 32-bit string made up of random ASCII values
            "oauth_nonce": UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
            "oauth_version": "1.0"
        ]
        
        // Add to parameters extra values
        if let extraParameters = extraParameters {
            parameters = parameters.merging(extraParameters) { (current, _) in current }
        }
        
        // Build the OAuth signature from parameters
//        let signature = SignatureHelper.createRequestSignature(httpMethod: method.rawValue, url: urlString, parameters: parameters, secretToken: access.secret)
//        parameters["oauth_signature"] = signature
        let signature: SignatureHelper = .init(httpMethod: method.rawValue, urlAsString: urlString, parameters: parameters, secretConsumerKey: FlickrAPI.consumerSecretKey.rawValue, secret: access.secret)
        parameters["oauth_signature"] = signature.getSignature()
        
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
                completion(.failure(ErrorMessage.error("HTTP response is empty.")))
                return
            }
            
            guard let data = data else {
                completion(.failure(ErrorMessage.error("Data response is empty.")))
                return
            }
            
            if let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                completion(.failure(ErrorMessage.error("Error Server Response: \(errorMessage.message)")))
                return
            }
            
            switch httpResponse.statusCode {
            case ..<200:
                completion(.failure(ErrorMessage.error("Informational message error (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            case ..<300:
                print("Status: \(httpResponse.statusCode) OK")
                do {
                    let response = try parser(data)
                    completion(.success(response))
                } catch (let parseError) {
                    completion(.failure(parseError))
                }
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
    
    // MARK: - Upload Methods
    
    func uploadRequest<Response>(
        params extraParameters: [String: String]? = nil,
        for fileData: Data,
        method: HttpMethodType,
        parser: @escaping (Data) throws -> Response,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        // Create URL
        let urlString = HttpEndpoint.uploadDomain.rawValue
        guard let url = URL(string: urlString) else { return }
        
        // Bild URL request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        

        
        var parameters: [String: String] = [
            "nojsoncallback": "1",
            "format": "json",
            "oauth_token": access.token,
            "oauth_consumer_key": FlickrAPI.consumerKey.rawValue,
            // Value 'nonce' can be any 32-bit string made up of random ASCII values
            "oauth_nonce": UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
            "oauth_version": "1.0"
        ]
        // Methods to prepare API requests
        let signature: SignatureHelper = .init(httpMethod: method.rawValue, urlAsString: urlString, parameters: parameters, secretConsumerKey: FlickrAPI.consumerSecretKey.rawValue, secret: access.secret)
        parameters["oauth_signature"] = signature.getSignature()
        
//        let signature = SignatureHelper.createRequestSignature(httpMethod: method.rawValue, url: urlString, parameters: parameters, secretToken: access.secret)
//        parameters["oauth_signature"] = signature
        
        // Generate HTTP body for URL request
        let multipart: MultipartHelper = .init(parameters: parameters, file: fileData)
//        var httpBody = Data()
//        
//        for (key, value) in parameters {
//            httpBody.appendString(multipartHelper.convertFormField(named: key, value: value, using: boundary))
//        }
//        
//        httpBody.append(multipartHelper.convertFileData(fieldName: "photo", fileName: "imagename.png", mimeType: "image/png", fileData: fileData, using: boundary))
//        
//        httpBody.appendString("--\(boundary)--")
        // Set 'Content-Type' for 'multipart/form-data'
        request.setValue(multipart.getContentType(), forHTTPHeaderField: "Content-Type")
        request.httpBody = multipart.getRequestData()
        
        // URL configuration
        let config = URLSessionConfiguration.default
        
        // Request creation
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ErrorMessage.error("HTTP response is empty.")))
                return
            }
            
            guard let data = data else {
                completion(.failure(ErrorMessage.error("Data response is empty.")))
                return
            }
            
            switch httpResponse.statusCode {
            case ..<200:
                completion(.failure(ErrorMessage.error("Informational message error (\(httpResponse.statusCode)).")))
            case ..<300:
                print("Status: \(httpResponse.statusCode) OK")
                do {
                    let response = try parser(data)
                    completion(.success(response))
                } catch (let parseError) {
                    completion(.failure(parseError))
                }
            case ..<400:
                completion(.failure(ErrorMessage.error("Redirection message (\(httpResponse.statusCode)).")))
            case ..<500:
                completion(.failure(ErrorMessage.error("Client request error (\(httpResponse.statusCode)).")))
            case ..<600:
                completion(.failure(ErrorMessage.error("Internal server error (\(httpResponse.statusCode)).")))
            default:
                completion(.failure(ErrorMessage.error("Unknown status code (\(httpResponse.statusCode)).")))
            }
            
        }
        
        // Start request process
        task.resume()
    }
    
    // MARK: - Response Decoders Entities
    
    // Error Response: ["message": Invalid NSID provided, "code": 1, "stat": fail]
    private struct ErrorResponse: Decodable {
        let message: String
        let code: Int
    }
    
    
    
    
    
    enum RequestType {
        case upload
        case request
    }
    
    enum ResponseFormat: String {
        case rest = "rest"
        case json = "json"
    }
    
    let session: URLSession = .init(configuration: .default)
    
    func request<Response>(
        for requestType: RequestType,
        methodAPI: Constant.FlickrMethod? = nil,
        with file: Data? = nil,
        parameters: [String: String]? = nil,
        token: String,
        secret: String,
        consumerKey: String,
        secretConsumerKey: String,
        httpMethod: HttpMethodType,
        formatType: ResponseFormat,
        parser: @escaping (Data) throws -> Response,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        // Create URL string
        let path = requestType == .request ? HttpEndpoint.requestDomain.rawValue : HttpEndpoint.uploadDomain.rawValue
        
        // Default parameters
        var params: [String: String] = [
            "nojsoncallback": "1",
            "format": formatType.rawValue,
            "oauth_token": token,
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
            "oauth_version": "1.0"
        ]
        
        // Add to parameters extra values
        if let extra = parameters {
            params = params.merging(extra) { (current, _) in current }
        }
        
        // Generate request signature and add to parameters
        let signature: SignatureHelper = .init(httpMethod: httpMethod.rawValue, urlAsString: path, parameters: params, secretConsumerKey: secretConsumerKey, secret: secret)
        params["oauth_signature"] = signature.getSignature()
        
        // Build URL request
        guard var request = buildURLRequest(httpMethod: httpMethod, path: path, params: params, fileData: file) else { return }
        request.httpMethod = httpMethod.rawValue
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ErrorMessage.error("HTTP response is empty.")))
                return
            }
            
            guard let data = data else {
                completion(.failure(ErrorMessage.error("Data response is empty.")))
                return
            }
            print(String(data: data, encoding: .utf8))
            switch httpResponse.statusCode {
            case ..<200:
                completion(.failure(ErrorMessage.error("Informational message error (\(httpResponse.statusCode)).")))
            case ..<300:
                print("Status: \(httpResponse.statusCode) OK")
                do {
                    let response = try parser(data)
                    completion(.success(response))
                } catch (let parseError) {
                    completion(.failure(parseError))
                }
            case ..<400:
                completion(.failure(ErrorMessage.error("Redirection message (\(httpResponse.statusCode)).")))
            case ..<500:
                completion(.failure(ErrorMessage.error("Client request error (\(httpResponse.statusCode)).")))
            case ..<600:
                completion(.failure(ErrorMessage.error("Internal server error (\(httpResponse.statusCode)).")))
            default:
                completion(.failure(ErrorMessage.error("Unknown status code (\(httpResponse.statusCode)).")))
            }
            
        }
        
        // Start request process
        task.resume()
    }
    
    private func buildURLRequest(httpMethod: HttpMethodType, path: String, params: [String: String], fileData: Data?) -> URLRequest? {
        switch httpMethod {
        case .POST:
            guard let url = URL(string: path) else { return nil }
            var request = URLRequest(url: url)
            
            let multipart: MultipartHelper = .init(parameters: params, file: fileData)
            
            // Set 'Content-Type' for 'multipart/form-data'
            request.setValue(multipart.getContentType(), forHTTPHeaderField: "Content-Type")
            request.httpBody = multipart.getRequestData()
            
            return request
        default:
            // Build URL request using URLComponents
            var components = URLComponents(string: path)
            
            components?.queryItems = params.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
            
            guard let url = components?.url else { return nil }
            return URLRequest(url: url)
        }
    }
    
}
