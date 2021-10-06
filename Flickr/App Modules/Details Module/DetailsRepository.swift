//
//  PostNetworkManager.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 04.10.2021.
//

import UIKit

class DetailsRepository {
    
    private let details: PostDetails
    private let networkService: NetworkService
    
    private let cacheImages: CacheStorageService<NSString, UIImage>
    private let cacheBuddyicons: CacheStorageService<NSString, UIImage>
    private let cachePostInformation: CacheStorageService<NSString, PostDetails>
    
    private var isFavourite: Bool = false
    
    init(details: PostDetails, networkService: NetworkService) {
        self.details = details
        self.networkService = networkService
        
        cacheImages = .init()
        cacheBuddyicons = .init()
        cachePostInformation = .init()
    }
    
    func getIsFavourite() -> Bool {
        self.isFavourite
    }
    
//    func requestPostInformation(position: Int, group: DispatchGroup, completionHandler: @escaping (Result<PostDetails, Error>) -> Void) {
//        group.enter()
//
//        let cachePostInformationIdentifier = ids[position] as NSString
//        if let postInformationCache = try? cachePostInformation.get(for: cachePostInformationIdentifier) {
//            completionHandler(.success(postInformationCache))
//            group.leave()
//            return
//        }
//
//        networkService.getPhotoById(with: ids[position]) { [weak self] result in
//            completionHandler(result.map {
//                self?.posts.append($0)
//                self?.cachePostInformation.set(for: $0, with: cachePostInformationIdentifier)
//                group.leave()
//                return $0
//            })
//        }
//    }
    
    func requestImage(post: PostDetails, group: DispatchGroup, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        group.enter()
        
        guard
            let id = post.id,
            let secret = post.secret,
            let server = post.server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            group.leave()
            return
        }
        
        let cacheImageIdentifier = id + secret + server as NSString
        if let imageCache = try? cacheImages.get(for: cacheImageIdentifier) {
            completionHandler(.success(imageCache))
            group.leave()
            return
        }
        
        networkService.image(postId: id, postSecret: secret, serverId: server) { [weak self] result in
            completionHandler(result.map {
                self?.cacheImages.set(for: $0, with: cacheImageIdentifier)
                group.leave()
                return $0
            })
        }
    }
    
    func requestBuddyicon(post: PostDetails, group: DispatchGroup, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        group.enter()
        
        guard
            let farm = post.owner?.iconFarm,
            let server = post.owner?.iconServer,
            let nsid = post.owner?.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            group.leave()
            return
        }
        
        let cacheBuddyiconIdentifier = String(farm) + server + nsid as NSString
        if let buddyiconCache = try? cacheBuddyicons.get(for: cacheBuddyiconIdentifier) {
            completionHandler(.success(buddyiconCache))
            group.leave()
            return
        }
        
        networkService.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { [weak self] result in
            completionHandler(result.map {
                self?.cacheBuddyicons.set(for: $0, with: cacheBuddyiconIdentifier)
                group.leave()
                return $0
            })
        }
    }
    
    func removeAllComments() {
        comments.removeAll()
    }
    
    func requestOwnerAvatar(comment: Comment, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        
        guard
            let farm = comment.iconFarm,
            let server = comment.iconServer,
            let nsid = comment.author
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        
        networkService.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { result in
            completionHandler(result.map {
                return $0
            })
        }
    }
    
    private var comments: [Comment] = []
    
    var numberOfComments: Int {
        comments.count
    }
    
    func getComment(index: Int) -> Comment? {
        comments[index] ?? nil
    }
    
    func requestComments(post: PostDetails, group: DispatchGroup, completionHandler: @escaping (Result<[Comment]?, Error>) -> Void) {
                group.enter()
        
//                let cachePostInformationIdentifier = ids[position] as NSString
//                if let postInformationCache = try? cachePostInformation.get(for: cachePostInformationIdentifier) {
//                    completionHandler(.success(postInformationCache))
//                    group.leave()
//                    return
//                }
        
        
        networkService.getPhotoComments(for: post.id!) { [weak self] result in
            completionHandler(result.map {
                self?.comments = $0 ?? []
                //self?.cachePostInformation.set(for: $0, with: cachePostInformationIdentifier)
                group.leave()
                return $0
            })
        }
    }
    
    func requestIsFavourite(group: DispatchGroup, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        group.enter()
        networkService.getFavorites { result in
            group.leave()
            switch result {
            case .success(let favourites):
                for fav in favourites {
                    if fav.id == self.details.id {
                        self.isFavourite = true
                        completionHandler(.success(true))
                        return
                    }
                }
                self.isFavourite = false
                completionHandler(.success(false))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func requestAddFavourite(id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.isFavourite = true
        networkService.addToFavorites(with: id, completion: completionHandler)
    }
    
    func requestRemoveFavourite(id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.isFavourite = false
        networkService.removeFromFavorites(with: id, completion: completionHandler)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
