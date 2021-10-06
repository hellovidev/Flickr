//
//  PostViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import Foundation
import UIKit

class PostViewModel {
    
    private let postNetworkManager: PostNetworkManager
    
    private let details:PostDetails
    
    weak var delegate: PostViewControllerDelegate?
    
    weak var coordinator: HomeCoordinator?
    
    init(coordinator: HomeCoordinator, details: PostDetails, networkService: NetworkService) {
        self.coordinator = coordinator
        self.postNetworkManager = .init(details: details, networkService: networkService)
        
        self.details = details //??
    }
    
    func close() {
        coordinator?.close()
    }
    
    var isFavourite: Bool {
        postNetworkManager.getIsFavourite()
    }
    
    func requestPost(completionHandler: @escaping (Result<Post, Never>) -> Void) {
        let builder: PostBuilder = .init(details: details, postNetworkManager: postNetworkManager)
        let director: PostDirector = .init()
        director.update(builder: builder)
        
        director.buildPost {
            let post = builder.retrievePost()
            completionHandler(.success(post))
        }
    }
    
    func requestAddFavourite(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        postNetworkManager.requestAddFavourite(id: details.id!, completionHandler: completionHandler)
    }
    
    func requestRemoveFavourite(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        postNetworkManager.requestRemoveFavourite(id: details.id!, completionHandler: completionHandler)
    }
    
    func requestOwnerAvatar(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard let comment = postNetworkManager.getComment(index: index) else { return }
        postNetworkManager.requestOwnerAvatar(comment: comment, completionHandler: completionHandler)
    }
    
}

struct Post {
    
    var id: String?
    var image: UIImage?
    var title: String?
    var description: String?
    var publishedAt: String?
    var isFavourite: Bool?
    var owner: Owner?
    
    struct Owner {
        var avatar: UIImage?
        var realName: String?
        var username: String?
        var location: String?
    }
    
    var comments: [Comment]?
    
    struct Comment {
        let owner: Owner?
        var content: String?
        let publishedAt: String?
    }
}

protocol Builder {

    func produceOwner(group: DispatchGroup)
    func produceImage(group: DispatchGroup)
    func produceDetails(group: DispatchGroup)
    func produceComments(group: DispatchGroup)
}

class PostBuilder: Builder {

    private let postNetworkManager: PostNetworkManager
    private let details: PostDetails
    
    private var product: Post = .init()
    
    init(details: PostDetails, postNetworkManager: PostNetworkManager) {
        self.postNetworkManager = postNetworkManager
        self.details = details
    }

    func reset() {
        product = Post()
    }

    func produceOwner(group: DispatchGroup) {
        product.owner = .init(realName: details.owner?.realName, username: details.owner?.username, location: details.owner?.location)
        
        postNetworkManager.requestBuddyicon(post: details, group: group) { [weak self] result in
            switch result {
            case .success(let avatar):
                self?.product.owner?.avatar = avatar
            case .failure(let error):
                print("Avatar download failed: \(error)")
            }
        }
    }
    
    func produceImage(group: DispatchGroup) {
        postNetworkManager.requestImage(post: details, group: group) { [weak self] result in
            switch result {
            case .success(let image):
                self?.product.image = image
            case .failure(let error):
                print("Image download failed: \(error)")
            }
        }
    }
    
    func produceDetails(group: DispatchGroup) {
        product.id = details.id
        product.title = details.title?.content
        product.description = details.description?.content
        product.publishedAt = details.dateUploaded
        
        postNetworkManager.requestIsFavourite(group: group) { [weak self] result in
            switch result {
            case .success(let isFavourite):
                self?.product.isFavourite = isFavourite
            case .failure(let error):
                print("Favourite status download failed: \(error)")
            }
        }
    }
    
    func produceComments(group: DispatchGroup) {
        postNetworkManager.requestComments(post: details, group: group) { [weak self] result in
            switch result {
            case .success(let comments):
                if let comments = comments {
                for comment in comments {
                    self?.product.comments?.append(Post.Comment(owner: Post.Owner(avatar: nil, realName: comment.realName, username: comment.authorName), content: comment.content, publishedAt: comment.dateCreate))
                }
                }
            case .failure(let error):
                print("Commets download failed: \(error)")
            }
        }
    }
    
//    func produceIsFavourite(group: DispatchGroup) {
//
//    }

    /// Concrete Builders are supposed to provide their own methods for
    /// retrieving results. That's because various types of builders may create
    /// entirely different products that don't follow the same interface.
    /// Therefore, such methods cannot be declared in the base Builder interface
    /// (at least in a statically typed programming language).
    ///
    /// Usually, after returning the end result to the client, a builder
    /// instance is expected to be ready to start producing another product.
    /// That's why it's a usual practice to call the reset method at the end of
    /// the `getProduct` method body. However, this behavior is not mandatory,
    /// and you can make your builders wait for an explicit reset call from the
    /// client code before disposing of the previous result.
    func retrievePost() -> Post {
        let result = self.product
        reset()
        return result
    }
    
}

class PostDirector {

    private var builder: Builder?

    func update(builder: Builder) {
        self.builder = builder
    }

    func buildPost(completionHandler: @escaping () -> Void) {
        let group: DispatchGroup = .init()
        
        builder?.produceOwner(group: group)
        builder?.produceImage(group: group)
        builder?.produceDetails(group: group)
        builder?.produceComments(group: group)
        
        group.notify(queue: DispatchQueue.main) {
            completionHandler()
        }
    }
    
}

// MARK: - PostViewControllerDelegate

protocol PostViewControllerDelegate: AnyObject {
    func close()
}
