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
class NetworkService: NSObject, ProgressDelegate {
    func onProgressCanceled() {
        uploadAlert.dismiss(animated: true)
        //progressAlert.dismiss(completion: nil)
    }
    
    private lazy var uploadAlert: UploadViewController = .init(delegate: self)

    
    //private lazy var progressAlert: ProgressAlert = .init(title: "Uploading...", delegate: self)
    private lazy var session: URLSession = .init(configuration: .default, delegate: self, delegateQueue: .main)
    
    // Token to get access to 'Flickr API'
    private var accessTokenAPI: AccessTokenAPI
    private let consumerKeyAPI: (publicKey: String, secretKey: String)
    private let signatureHelper: SignatureHelper
    
    // Without access token 'NetworkService' do not work
    /// Initialization of network service
    /// - token: Access token of API
    /// - public: Public API key of your account
    /// - secret: Public API key of your account
    init(token: AccessTokenAPI, publicKey: String, secretKey: String) {
        self.accessTokenAPI = token
        self.consumerKeyAPI = (publicKey, secretKey)
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
        
        DispatchQueue.main.async { [weak self] in
            self?.startUploading()
        }
        
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
            
            //print(String(data: data, encoding: .utf8))
            if let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                completion(.failure(ErrorMessage.error("Error Callback by Flickr: \(errorMessage.message)")))
                return
            }
            
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
    
    
    var uploadProgress: Float = 0 {
        didSet {
            uploadAlert.setProgress(uploadProgress)
            
            //let percentProgress = uploadProgress * 100
            //progressAlert.setProgress(uploadProgress)
            //print(uploadProgress)
        }
    }
    
    // MARK: - Response Decoders Entities
    
    // Error Response: ["message": Invalid NSID provided, "code": 1, "stat": fail]
    private struct ErrorResponse: Decodable {
        let stat: String
        let message: String
        let code: Int
    }
    
    func startUploading() {
        var rootViewController = UIApplication.shared.windows.first?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        
        guard let vc = rootViewController else {return}
        uploadAlert.present(from: vc)
    }
    
    //var count = false
    
}


extension NetworkService: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        showAlert(title: "Upload Error", message: "Uploading image complete with failure.", button: "OK")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        //let progressPercent = Int(uploadProgress*100)
        
        self.uploadProgress = uploadProgress
        
//        if count == false {
//            var rootViewController = UIApplication.shared.windows.first?.rootViewController
//            if let navigationController = rootViewController as? UINavigationController {
//                rootViewController = navigationController.viewControllers.first
//            }
//            if let tabBarController = rootViewController as? UITabBarController {
//                rootViewController = tabBarController.selectedViewController
//            }
//
//            guard let vc = rootViewController else {return}
//            uploadAlert.present(from: vc)
//            //progressAlert.present(from: vc)
//            count = true
//        }
    }
    
}

import UIKit

func showAlert(title: String, message: String, button: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(.init(title: button, style: .default, handler: nil))
    UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
}

//func showAlert() {
//    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
//
//    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
//    loadingIndicator.hidesWhenStopped = true
//    loadingIndicator.style = UIActivityIndicatorView.Style.gray
//    loadingIndicator.startAnimating();
//
//    alert.view.addSubview(loadingIndicator)
//    present(alert, animated: true, completion: nil)
//
//    alertController.addAction(.init(title: button, style: .default, handler: nil))
//    UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
//}



protocol ProgressDelegate: AnyObject {
    func onProgressCanceled()
}

class ProgressAlert {
    
    private let alert: UIAlertController
    private var progressBar: UIProgressView
    
    private weak var delegate: ProgressDelegate?
    
    private let labelPercent: UILabel
    
    init(title: String, delegate: ProgressDelegate?) {
        self.delegate = delegate
        alert = UIAlertController(title: title, message: "",
                                  preferredStyle: .alert)
        
        progressBar = UIProgressView(progressViewStyle: .default)
        labelPercent = UILabel()
        labelPercent.font = .systemFont(ofSize: 10)
        labelPercent.textAlignment = .center
        
        //    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { alertAction in
        //        delegate?.onProgressCanceled()
        //    })
    }
    
    func present(from viewController: UIViewController) {
        viewController.present(alert, animated: true) { [weak self] in
            let margin: CGFloat = 24.0
            let rectangle = CGRect(x: margin, y: 55.0, width: (self?.alert.view.frame.width)! - margin * 2.0, height: 2.0)
            self?.progressBar.frame = rectangle
            
            let rectangleLabel = CGRect(x: margin, y: 40.0, width: (self?.alert.view.frame.width)! - margin * 2.0, height: 15.0)
            self?.labelPercent.frame = rectangleLabel
            
            self?.alert.view.addSubview(self!.progressBar)
            self?.alert.view.addSubview(self!.labelPercent)
        }
    }
    
    func dismiss(completion: (() -> Void)?) {
        
        alert.dismiss(animated: true, completion: completion)
    }
    
    func setProgress(_ value: Float) {
        labelPercent.text = "\(Int(value * 100))%"
        progressBar.setProgress(value, animated: true)
        if value == 1.0 {
            delegate?.onProgressCanceled()
        }
        print("Updating download: \(value)")
    }
}
