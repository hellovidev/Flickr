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
    private let access: AccessTokenAPI
    
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
        complition: @escaping (Result<Response, Error>) -> Void
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
        let signature = SignatureHelper.createRequestSignature(httpMethod: method.rawValue, url: urlString, parameters: parameters, secretToken: access.secret)
        parameters["oauth_signature"] = signature
        
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
                complition(.failure(ErrorMessage.error("HTTP response is empty.")))
                return
            }
            
            guard let data = data else {
                complition(.failure(ErrorMessage.error("Data response is empty.")))
                return
            }
            
            if let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                complition(.failure(ErrorMessage.error("Error Server Response: \(errorMessage.message)")))
                return
            }
            
            switch httpResponse.statusCode {
            case ..<200:
                complition(.failure(ErrorMessage.error("Informational message error (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            case ..<300:
                print("Status: \(httpResponse.statusCode) OK")
                do {
                    let response = try parser(data)
                    complition(.success(response))
                } catch (let parseError) {
                    complition(.failure(parseError))
                }
            case ..<400:
                complition(.failure(ErrorMessage.error("Redirection message (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            case ..<500:
                complition(.failure(ErrorMessage.error("Client request error (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            case ..<600:
                complition(.failure(ErrorMessage.error("Internal server error (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
            default:
                complition(.failure(ErrorMessage.error("Unknown status code (\(httpResponse.statusCode)). Error: \(String(describing: error))")))
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
        complition: @escaping (Result<Response, Error>) -> Void
    ) {
        // Create URL
        let urlString = HttpEndpoint.uploadDomain.rawValue
        guard let url = URL(string: urlString) else { return }
        
        // Bild URL request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set 'Content-Type' for 'multipart/form-data'
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
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
        let signature = SignatureHelper.createRequestSignature(httpMethod: method.rawValue, url: urlString, parameters: parameters, secretToken: access.secret)
        parameters["oauth_signature"] = signature
        
        // Generate HTTP body for URL request
        let multipartHelper: MultipartHelper = .init()
        let httpBody = NSMutableData()
        
        for (key, value) in parameters {
            httpBody.appendString(multipartHelper.convertFormField(named: key, value: value, using: boundary))
        }
        
        httpBody.append(multipartHelper.convertFileData(fieldName: "photo", fileName: "imagename.png", mimeType: "image/png", fileData: fileData, using: boundary))
        
        httpBody.appendString("--\(boundary)--")
        request.httpBody = httpBody as Data
        
        // URL configuration
        let config = URLSessionConfiguration.default
        
        // Request creation
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { data, response, error in
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
                print("Status: \(httpResponse.statusCode) OK")
                do {
                    let response = try parser(data)
                    complition(.success(response))
                } catch (let parseError) {
                    complition(.failure(parseError))
                }
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
    
    // MARK: - Response Decoders Entities
    
    // Error Response: ["message": Invalid NSID provided, "code": 1, "stat": fail]
    private struct ErrorResponse: Decodable {
        let message: String
        let code: Int
    }
    
}
