//
//  NetworkService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.08.2021.
//

import Foundation

// MARK: - API Access Structure

struct AccessTokenAPI: Codable {
    let token: String
    let secret: String
    let nsid: String
}

// MARK: - Network Layer (REST)

/// https://www.flickr.com/services/api/
struct NetworkService {
    
    private let session: URLSession = .init(configuration: .default)
    
    let cacheService: CacheStorageService = .init()
    
    //let cacheService: CacheStorageService<AnyObject, AnyObject> = .init()
    
    // Token to get access to 'Flickr API'
    private var accessTokenAPI: AccessTokenAPI
    private let consumerKeyAPI: (publicKey: String, secretKey: String)
    private let signatureHelper: SignatureHelper

    // Without access token 'NetworkService' do not work
    init(accessTokenAPI: AccessTokenAPI, publicConsumerKey: String, secretConsumerKey: String) {
        self.accessTokenAPI = accessTokenAPI
        self.consumerKeyAPI = (publicConsumerKey, secretConsumerKey)
        self.signatureHelper = .init(consumerSecretKey: consumerKeyAPI.secretKey, accessSecretToken: accessTokenAPI.secret)
    }
    
    func request<Serializer: Deserializer>(
        parameters: [String: String]? = nil,
        type: String,
        endpoint: String,
        method: HTTPMethod,
        parser: Serializer,
        completion: @escaping (Result<Serializer.Response, Error>) -> Void
    ) {        
        // Default parameters
        var params: [String: String] = [
            "nojsoncallback": "1",
            "format": "json",
            "method": type,
            "oauth_token": accessTokenAPI.token,
            "oauth_consumer_key": consumerKeyAPI.publicKey,
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
        let signature = signatureHelper.buildSignature(method: method.rawValue, endpoint: endpoint, parameters: params)
        params["oauth_signature"] = signature
        
        // Build URL request using URLComponents
        var components = URLComponents(string: endpoint)
        
        components?.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components?.url else {
            completion(.failure(ErrorMessage.error("URL could not be created at line \(#line) and function \(#function).")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        self.request(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try parser.parse(data: data)
                    completion(.success(response))
                } catch (let parseError) {
                    completion(.failure(parseError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func upload<Serializer: Deserializer>(
        parameters: [String: String]? = nil,
        file: Data,
        endpoint: String,
        parser: Serializer,
        completion: @escaping (Result<Serializer.Response, Error>) -> Void
    ) {
        // Default parameters
        var params: [String: String] = [
            "nojsoncallback": "1",
            "format": "json",
            "oauth_token": accessTokenAPI.token,
            "oauth_consumer_key": consumerKeyAPI.publicKey,
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
        let signature = signatureHelper.buildSignature(method: HTTPMethod.POST.rawValue, endpoint: endpoint, parameters: params)
        params["oauth_signature"] = signature
        
        // Build URL request using multipart/form-data
        guard let url = URL(string: endpoint) else {
            completion(.failure(ErrorMessage.error("URL could not be created at line \(#line) and function \(#function).")))
            return
        }
        
        var request = URLRequest(url: url)
        
        let multipart: MultipartHelper = .init(parameters: params, file: file)
        
        // Set 'Content-Type' for 'multipart/form-data'
        request.setValue(multipart.getContentType(), forHTTPHeaderField: "Content-Type")
        request.httpBody = multipart.getRequestData()
        request.httpMethod = HTTPMethod.POST.rawValue
        
        self.request(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try parser.parse(data: data)
                    completion(.success(response))
                } catch (let parseError) {
                    completion(.failure(parseError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
        
    private func request(
        request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        // Create URLSession task
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ErrorMessage.error("HTTP response is empty.")))
                return
            }
            
            guard let data = data else {
                completion(.failure(ErrorMessage.error("Data response is empty.")))
                return
            }
            
//            print(String(data: data, encoding: .utf8))
//            if let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
//                completion(.failure(ErrorMessage.error("Error Server Response: \(errorMessage.message)")))
//                return
//            }

            switch httpResponse.statusCode {
            case ..<200:
                completion(.failure(ErrorMessage.error("Informational message error (\(httpResponse.statusCode)).")))
            case ..<300:
                print("Status: \(httpResponse.statusCode) OK")
                completion(.success(data))
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
    
    func request(for url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        if let cachedData = try? cacheService.get(for: url.absoluteString as NSString) {//ImageCache.shared.get(with: url.absoluteString as NSString) {
            print("IMAGE USE CACHE")
            completionHandler(.success(cachedData as! Data))
            return
        }

        let task = session.downloadTask(with: url) { fileURL, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(NetworkError.badHTTPResponse))
                return
            }
            
            guard let fileURL = fileURL else {
                completionHandler(.failure(NetworkError.badResponseURL))
                return
            }
            
            do {
                let data = try Data(contentsOf: fileURL)
                self.cacheService.set(for: data as NSData, with: url.absoluteString as NSString)
                //ImageCache.shared.set(for: data as NSData, with: url.absoluteString as NSString)
                completionHandler(.success(data))
            } catch {
                completionHandler(.failure(error))
            }
        }
        
        task.resume()
    }
 
    // MARK: - Response Decoders Entities
    
    // Error Response: ["message": Invalid NSID provided, "code": 1, "stat": fail]
    private struct ErrorResponse: Decodable {
        let message: String
        let code: Int
    }
    
}
