//
//  PostNetworkManager.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 04.10.2021.
//

import UIKit

class DetailsRepository {
    
    private let id: String
    private var isFavourite: Bool = false
    private var details: Post = .init()

    @Dependency private var network: NetworkService
    
    private let cacheDetailsOwnerAvatar: CacheStorageService<NSString, UIImage>
    private let cacheDetailsImage: CacheStorageService<NSString, UIImage>
    private let cacheCommentOwnerAvatar: CacheStorageService<NSString, UIImage>
    
    //private let cacheDetails: CacheStorageService<NSString, Post>
    //private let cacheComment: CacheStorageService<NSString, CommentProtocol>

    init(id: String) {
        self.id = id
        //self.network = network
        
        cacheDetailsOwnerAvatar = .init()
        cacheDetailsImage = .init()
        cacheCommentOwnerAvatar = .init()
    }
        
    // MARK: - Request Methods
    
    func requestPreparatoryDataOfDetails(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        network.getPhotoById(id: id) { [weak self] result in
            switch result {
            case .success(let details):
                self?.details.id = details.id
                self?.details.secret = details.secret
                self?.details.server = details.server
                self?.details.title = details.title?.content
                self?.details.description = details.description?.content
                self?.details.publishedAt = details.dateUploaded
                self?.details.owner = .init(realName: details.owner?.realName, username: details.owner?.username, location: details.owner?.location, iconFarm: details.owner?.iconFarm, iconServer: details.owner?.iconServer, nsid: details.owner?.nsid)
                completionHandler(.success(Void()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func collectDetailsOwnerAvatar(group: DispatchGroup) {
        requestDetailsOwnerAvatar(post: details, group: group) { [weak self] result in
            switch result {
            case .success(let avatar):
                self?.details.owner?.avatar = avatar
            case .failure(let error):
                print("Post owner avatar download failed: \(error)")
            }
        }
    }
    
    private func requestDetailsOwnerAvatar(post: Post, group: DispatchGroup, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
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
        
        let cacheDetailsOwnerAvatarIdentifier = String(farm) + server + nsid as NSString
        if let ownerAvatarCache = try? cacheDetailsOwnerAvatar.get(for: cacheDetailsOwnerAvatarIdentifier) {
            completionHandler(.success(ownerAvatarCache))
            group.leave()
            return
        }
        
        network.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { [weak self] result in
            group.leave()
            
            completionHandler(result.map {
                self?.cacheDetailsOwnerAvatar.set(for: $0, with: cacheDetailsOwnerAvatarIdentifier)
                return $0
            })
        }
    }
    
    func collectDetailsImage(group: DispatchGroup) {
        requestDetailsImage(post: details, group: group) { [weak self] result in
            switch result {
            case .success(let image):
                self?.details.image = image
            case .failure(let error):
                print("Post image download failed: \(error)")
            }
        }
    }
    
    private func requestDetailsImage(post: Post, group: DispatchGroup, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
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
        
        let cacheDetailsImageIdentifier = id + secret + server as NSString
        if let imageCache = try? cacheDetailsImage.get(for: cacheDetailsImageIdentifier) {
            completionHandler(.success(imageCache))
            group.leave()
            return
        }
        
        network.image(postId: id, postSecret: secret, serverId: server) { [weak self] result in
            group.leave()
            
            completionHandler(result.map {
                self?.cacheDetailsImage.set(for: $0, with: cacheDetailsImageIdentifier)
                return $0
            })
        }
    }
    
    func collectIsFavourite(group: DispatchGroup) {
        requestIsFavourite(group: group) { [weak self] result in
            switch result {
            case .success(let isFavourite):
                self?.details.isFavourite = isFavourite
            case .failure(let error):
                print("Favourite status download failed: \(error)")
            }
        }
    }
    
    private func requestIsFavourite(group: DispatchGroup, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        group.enter()
        
        network.getFavorites { [weak self] result in
            group.leave()
            
            switch result {
            case .success(let favourites):
                for favourite in favourites {
                    if favourite.id == self?.details.id {
                        self?.isFavourite = true
                        completionHandler(.success(true))
                        return
                    }
                }
                self?.isFavourite = false
                completionHandler(.success(false))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func requestAddFavourite(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        network.addToFavorites(with: id) { [weak self] result in
            completionHandler(result.map {
                self?.isFavourite = true
            })
        }
    }
    
    func requestRemoveFavourite(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        network.removeFromFavorites(with: id) { [weak self] result in
            completionHandler(result.map {
                self?.isFavourite = false
            })
        }
    }
    
    func collectDetailsComments(group: DispatchGroup) {
        group.enter()
        
        network.getPhotoComments(for: id) { [weak self] result in
            group.leave()
            
            switch result {
            case .success(let comments):
                self?.details.comments = .init()
                guard let comments = comments else { return }
                for comment in comments {
                    let detailsComment: PhotoComment = .init(iconFarm: comment.iconFarm, iconServer: comment.iconServer, nsid: comment.nsid, username: comment.authorName, commentContent: comment.content, publishedAt: comment.dateCreate)
                    self?.details.comments?.append(detailsComment)
                }
            case .failure(let error):
                print("Commets download failed: \(error)")
            }
        }
    }
    
    func requestCommentOwnerAvatar(comment: CommentOwnerProtocol, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard
            let farm = comment.iconFarm,
            let server = comment.iconServer,
            let nsid = comment.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        let cacheCommentOwnerAvatarIdentifier = String(farm) + server + nsid as NSString
        if let commentOwnerAvatarCache = try? cacheCommentOwnerAvatar.get(for: cacheCommentOwnerAvatarIdentifier) {
            completionHandler(.success(commentOwnerAvatarCache))
            return
        }
        
        network.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { [weak self] result in
            completionHandler(result.map {
                self?.cacheCommentOwnerAvatar.set(for: $0, with: cacheCommentOwnerAvatarIdentifier)
                return $0
            })
        }
    }
    
    func removeAllComments() {
        details.comments?.removeAll()
    }
    
    func numberOfComments() -> Int {
        guard let count = details.comments?.count else { return 0 }
        return count
    }
    
    func retrieveCommentAt(index: Int) -> (CommentProtocol & CommentOwnerProtocol)? {
        guard let comments = details.comments else { return nil }
        return comments[index]
    }
    
    func retrieveDetails() -> Post {
        self.details
    }
    
    func getIsFavourite() -> Bool {
        self.isFavourite
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
