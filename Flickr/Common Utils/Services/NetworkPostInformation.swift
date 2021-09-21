//
//  Network.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.09.2021.
//

import UIKit

enum NetworkManagerError: Error {
    case invalidParameters
}

enum ResponseSource {
    case cache
    case network
}

struct PostImage {
    let image: UIImage
    let type: ResponseSource
}

struct PostInformation {
    let information: PostDetails
    let type: ResponseSource
}

class NetworkPostInformation {
    
    private let networkService: NetworkService
    private let cacheImages: CacheStorageService<NSString, UIImage>
    private let cacheBuddyicons: CacheStorageService<NSString, UIImage>
    private let cachePostInformation: CacheStorageService<NSString, PostDetails>
    
    private var ids: [String]
    private var page: Int
    
    var idsCount: Int {
        ids.count
    }
    
    init(_ token: AccessTokenAPI) {
        self.networkService = .init(token: token, publicKey: FlickrConstant.Key.consumerKey.rawValue, secretKey: FlickrConstant.Key.consumerSecretKey.rawValue)
        self.cacheImages = .init()
        self.cacheBuddyicons = .init()
        self.cachePostInformation = .init()
        self.ids = .init()
        self.page = 1
    }
    
    private func addUniqValues(_ array: [Photo]) {
        ids += array.compactMap { $0.id }
        ids = ids.uniques
    }
    
    func refresh() {
        page = 1
        ids.removeAll()
        cacheImages.removeAll()
        cacheBuddyicons.removeAll()
        cachePostInformation.removeAll()
    }
    
    func requestPostsId(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        networkService.getRecentPosts(page: page) { [weak self] result in
            completionHandler(result.map {
                self?.page += 1
                self?.addUniqValues($0)
                return Void()
            })
        }
    }
    
    func requestPostInformation(position: Int, completionHandler: @escaping (Result<PostInformation, Error>) -> Void) {
        let cachePostInformationIdentifier = ids[position] as NSString
        if let postInformationCache = try? cachePostInformation.get(for: cachePostInformationIdentifier) {
            let postInformation = PostInformation(information: postInformationCache, type: .cache)
            completionHandler(.success(postInformation))
            return
        }
        
        networkService.getPhotoById(with: ids[position]) { [weak self] result in
            completionHandler(result.map {
                self?.cachePostInformation.set(for: $0, with: cachePostInformationIdentifier)
                let postInformation = PostInformation(information: $0, type: .network)
                return postInformation
            })
        }
    }
    
    func requestImage(post: PostDetails, completionHandler: @escaping (Result<PostImage, Error>) -> Void) {
        guard
            let id = post.id,
            let secret = post.secret,
            let server = post.server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        let cacheImageIdentifier = id + secret + server as NSString
        if let imageCache = try? cacheImages.get(for: cacheImageIdentifier) {
            let postImage = PostImage(image: imageCache, type: .cache)
            completionHandler(.success(postImage))
            return
        }
        
        networkService.image(postId: id, postSecret: secret, serverId: server) { [weak self] result in
            completionHandler(result.map {
                self?.cacheImages.set(for: $0, with: cacheImageIdentifier)
                let postImage = PostImage(image: $0, type: .network)
                return postImage
            })
        }
    }
    
    func requestBuddyicon(post: PostDetails, completionHandler: @escaping (Result<PostImage, Error>) -> Void) {
        guard
            let farm = post.owner?.iconFarm,
            let server = post.owner?.iconServer,
            let nsid = post.owner?.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        let cacheBuddyiconIdentifier = String(farm) + server + nsid as NSString
        if let buddyiconCache = try? cacheBuddyicons.get(for: cacheBuddyiconIdentifier) {
            let postBuddyicon = PostImage(image: buddyiconCache, type: .cache)
            completionHandler(.success(postBuddyicon))
            return
        }
        
        networkService.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { [weak self] result in
            completionHandler(result.map {
                self?.cacheBuddyicons.set(for: $0, with: cacheBuddyiconIdentifier)
                let postBuddyicon = PostImage(image: $0, type: .network)
                return postBuddyicon
            })
        }
    }
    
}

// MARK: - Array Unique Values

extension Array where Element: Hashable {
    
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
}
