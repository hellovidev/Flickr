//
//  NetworkService+ImageDownload.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 14.09.2021.
//

import UIKit

/// Image size.
/// - s: thumbnail 75 cropped square
/// - q: thumbnail 150 cropped square
/// - t: thumbnail 100
/// - m: small 240
/// - n: small 320
/// - w: small 400
/// - none: (empty) medium 500
/// - z: medium 640
/// - c: medium 800
/// - b: large 1024
/// - h: large 1600 has a unique secret; photo owner can restrict
/// - k: large 2048 has a unique secret; photo owner can restrict
/// - k3: extra large 3072 has a unique secret; photo owner can restrict
/// - k4: extra large 4096 has a unique secret; photo owner can restrict
/// - f: extra large 4096 has a unique secret; photo owner can restrict; only exists for 2:1 aspect ratio photos
/// - k5: extra large 5120 has a unique secret; photo owner can restrict
/// - k6: extra large 6144 has a unique secret; photo owner can restrict
/// - o: original (arbitrary) has a unique secret; photo owner can restrict; files have full EXIF data; files might not be rotated; files can use an arbitrary file extension
enum ImageSize: String {
    case s
    case q
    case t
    case m
    case n
    case w
    case none = ""
    case z
    case c
    case b
    case h
    case k
    case k3 = "3k"
    case k4 = "4k"
    case f
    case k5 = "5k"
    case k6 = "6k"
    case o
}

enum ImageFormat: String {
    case jpg
    case png
}

enum NetworkError: Error {
    case badResponseURL
    case badHTTPResponse
}

enum URLError: Error {
    case invalidURL
}

enum ImageCacheError: Error {
    case nilObjectForKey(NSString)
}

class ImageCache {
    
    static let shared = ImageCache()
    
    private let cache: NSCache<NSString, NSData> = .init()
    
    func set(for data: NSData, with key: NSString) {
        cache.setObject(data, forKey: key)
    }
    
    func get(with key: NSString) throws -> NSData {
        guard let data = cache.object(forKey: key) else {
            throw ImageCacheError.nilObjectForKey(key)
        }
        return data
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
    
}

extension NetworkService {
    
    mutating func image(postId: String, postSecret: String, serverId: String, size: ImageSize = .z, format: ImageFormat = .jpg, completionHandler: @escaping (Result<UIImage?, Error>) -> Void) {
        guard
            let url = URL(string: "https://live.staticflickr.com/\(serverId)/\(postId)_\(postSecret)_\(size.rawValue).\(format.rawValue)")
        else {
            completionHandler(.failure(URLError.invalidURL))
            return
        }
        
        request(for: url) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    completionHandler(.success(image))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    mutating func buddyicon(iconFarm: Int, iconServer: String, nsid: String, completionHandler: @escaping (Result<UIImage?, Error>) -> Void) {
        guard
            let url = URL(string: Int(iconServer) == 0 ? "https://www.flickr.com/images/buddyicon.gif" : "http://farm\(iconFarm).staticflickr.com/\(iconServer)/buddyicons/\(nsid).jpg")
        else {
            completionHandler(.failure(URLError.invalidURL))
            return
        }
        
        request(for: url) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    completionHandler(.success(image))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
}
