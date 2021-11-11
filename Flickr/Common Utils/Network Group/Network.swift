//
//  Network.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.08.2021.
//

import UIKit

// MARK: - API Access Structure

struct AccessTokenAPI: Codable {
    let token: String
    let secret: String
    let nsid: String
}

// Error Response: ["message": Invalid NSID provided, "code": 1, "stat": fail]
private struct ErrorResponse: Decodable {
    let stat: String
    let message: String
    let code: Int
}

enum NetworkManagerError: Error {
    case invalidParameters
    case nilResponseData
}

// MARK: - Network

public class Network: NSObject, DependencyProtocol {
    
    private lazy var uploadAlert: UploadProgressViewController = .init(delegate: self)
    private lazy var session: URLSession = .init(configuration: .default, delegate: self, delegateQueue: .main)
    
    private var uploadProgress: Float = 0 {
        didSet {
            uploadAlert.setProgress(uploadProgress)
        }
    }
    
    // MARK: - Response Decoders Entities
    
    private var accessTokenAPI: AccessTokenAPI
    private let consumerKeyAPI: (publicKey: String, secretKey: String)
    private let signatureBuilder: SignatureBuilder
    
    /// Without access token 'Network' do not work
    /// - token: Access token of API
    /// - public: Public API key of your account
    /// - secret: Public API key of your account
    init(token: AccessTokenAPI, publicKey: String, secretKey: String) {
        self.accessTokenAPI = token
        self.consumerKeyAPI = (publicKey, secretKey)
        self.signatureBuilder = .init(consumerSecretKey: consumerKeyAPI.secretKey, accessSecretToken: accessTokenAPI.secret)
    }
    
    // MARK: - Foundation Methods
    
    func request<Serializer: Deserializer>(
        parameters: [String: String]? = nil,
        type: String,
        endpoint: String,
        method: HTTPMethod,
        parser: Serializer,
        completionHandler: @escaping (Result<Serializer.Response, Error>) -> Void
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
            "oauth_version": "1.0",
            "perms": "delete"
        ]
        
        // Add to parameters extra values
        if let extra = parameters {
            params = params.merging(extra) { (current, _) in current }
        }
        
        // Generate request signature and add to parameters
        var signature = signatureBuilder.buildSignature(method: method.rawValue, endpoint: endpoint, parameters: params)
        //print(signature)
        while signature.contains("+") {
            params["oauth_nonce"] = UUID().uuidString
            signature = signatureBuilder.buildSignature(method: method.rawValue, endpoint: endpoint, parameters: params)
        }
        //print(signature)
        params["oauth_signature"] = signature
        
        // Build URL request using URLComponents
        var components = URLComponents(string: endpoint)
        
        components?.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components?.url else {
            completionHandler(.failure(ErrorMessage.error("URL could not be created at line \(#line) and function \(#function).")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        self.request(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try parser.parse(data: data)
                    completionHandler(.success(response))
                } catch (let parseError) {
                    completionHandler(.failure(parseError))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func upload<Serializer: Deserializer>(
        parameters: [String: String]? = nil,
        file: Data,
        endpoint: String,
        parser: Serializer,
        completionHandler: @escaping (Result<Serializer.Response, Error>) -> Void
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
        let signature = signatureBuilder.buildSignature(method: HTTPMethod.POST.rawValue, endpoint: endpoint, parameters: params)
        params["oauth_signature"] = signature
        
        // Build URL request using multipart/form-data
        guard let url = URL(string: endpoint) else {
            completionHandler(.failure(ErrorMessage.error("URL could not be created at line \(#line) and function \(#function).")))
            return
        }
        
        var request = URLRequest(url: url)
        
        let multipart: MultipartHelper = .init(parameters: params, file: file)
        
        // Set 'Content-Type' for 'multipart/form-data'
        request.setValue(multipart.getContentType(), forHTTPHeaderField: "Content-Type")
        request.httpBody = multipart.getRequestData()
        request.httpMethod = HTTPMethod.POST.rawValue
        
        DispatchQueue.main.async { [weak self] in
            self?.startUploading()
        }
        
        self.request(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try parser.parse(data: data)
                    completionHandler(.success(response))
                } catch (let parseError) {
                    completionHandler(.failure(parseError))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func request(request: URLRequest, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(ErrorMessage.error("HTTP response is empty.")))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(ErrorMessage.error("Data response is empty.")))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            
            if let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                completionHandler(.failure(ErrorMessage.error("Error Callback by Flickr: \(errorMessage.message)")))
                return
            }
            
            switch httpResponse.statusCode {
            case ..<200:
                completionHandler(.failure(ErrorMessage.error("Informational message error (\(httpResponse.statusCode)).")))
            case ..<300:
                print("Status: \(httpResponse.statusCode) OK")
                completionHandler(.success(data))
            case ..<400:
                completionHandler(.failure(ErrorMessage.error("Redirection message (\(httpResponse.statusCode)).")))
            case ..<500:
                completionHandler(.failure(ErrorMessage.error("Client request error (\(httpResponse.statusCode)).")))
            case ..<600:
                completionHandler(.failure(ErrorMessage.error("Internal server error (\(httpResponse.statusCode)).")))
            default:
                completionHandler(.failure(ErrorMessage.error("Unknown status code (\(httpResponse.statusCode)).")))
            }
        }
        
        task.resume()
    }
    
    func request(for url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
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
                completionHandler(.success(data))
            } catch {
                completionHandler(.failure(error))
            }
        }
        
        task.resume()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

// MARK: - Network+URLSessionTaskDelegate

extension Network: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        let rootViewController = returnCurrentViewController()
        guard let viewController = rootViewController else { return }
        viewController.showAlert(title: "Upload Error", message: "Uploading image complete with failure.", button: "OK")
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        self.uploadProgress = uploadProgress
    }
    
    func startUploading() {
        let rootViewController = returnCurrentViewController()
        guard let viewController = rootViewController else { return }
        uploadAlert.present(from: viewController)
    }
    
    private func returnCurrentViewController() -> UIViewController? {
        var rootViewController = UIApplication.shared.windows.first?.rootViewController
        
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        
        return rootViewController
    }
    
}

// MARK: - Network+ProgressDelegate

extension Network: ProgressDelegate {
    
    func onProgressCanceled() {
        uploadAlert.dismiss(animated: true)
    }
    
}
