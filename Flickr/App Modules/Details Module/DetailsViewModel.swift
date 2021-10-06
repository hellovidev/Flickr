//
//  DetailsViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import Foundation
import UIKit

class DetailsViewModel {
    
    private let repository: DetailsRepository
    
    private weak var coordinator: HomeCoordinator?

    weak var delegate: DetailsViewControllerDelegate?
    
    
    
    
    
    
    
    private let details: PostDetails
    
    
    
    
    init(coordinator: HomeCoordinator, details: PostDetails, networkService: NetworkService) {
        self.coordinator = coordinator
        self.repository = .init(details: details, networkService: networkService)
        
        self.details = details //??
    }
    
    func close() {
        coordinator?.close()
    }
    
    var isFavourite: Bool {
        repository.getIsFavourite()
    }
    
    var numberOfComments: Int {
        return 5
        //postNetworkManager.numberOfComments
    }
    

    
    func refresh() {
        repository.removeAllComments()
    }
    
    func requestNextComments(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        completionHandler(.success(Void()))
    }
    
    func commentForRowAt(index: Int, completionHandler: @escaping (CommentProtocol) -> Void) {
        //let commentNetwork = postNetworkManager.getComment(index: index)
        
        var comment: PhotoComment
        if Bool.random() {
            comment = .init(ownerAvatar: nil, username: "samkitty", commentContent: "The game in Japan was amazing and I want to share some photos. The game in Japan was amazing and I want to share some photos", publishedAt: "2135123213")
        } else {
            comment = .init(ownerAvatar: nil, username: "sally69", commentContent: "I want to share some photos! Japan was amazing and I want to share some photos. The game in Japan was amazing and .... I want to share some photos! Japan was amazing and I want to share some photos. The game in Japan was amazing and ....", publishedAt: "2135123213")
        }
        
        //var comment: PhotoComment = .init(ownerAvatar: nil, username: commentNetwork?.authorName, commentContent: commentNetwork?.content, publishedAt: commentNetwork?.dateCreate)
        
        requestOwnerAvatar(index: index) { result in
            switch result {
            case .success(let ownerAvatar):
                comment.ownerAvatar = ownerAvatar
            case .failure(let error):
                print("Download owner avatar for comment with index \(index) failed. Error: \(error)")
            }
            completionHandler(comment)
        }
        
        completionHandler(comment)
    }
    
    func requestPost(completionHandler: @escaping (Result<Post, Error>) -> Void) {
        let builder: DetailBuilder = .init(detailId: details.id!, repository: repository)
        let director: PostDirector = .init()
        director.update(builder: builder)
        
        director.startProduction { result in
            switch result {
                
            case .success:
                let post = builder.retrievePost()
                completionHandler(.success(post))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
//        director.buildPost {
//            let post = builder.retrievePost()
//            completionHandler(.success(post))
//        }
    }
    
    func requestAddFavourite(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.requestAddFavourite(id: details.id!, completionHandler: completionHandler)
    }
    
    func requestRemoveFavourite(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.requestRemoveFavourite(id: details.id!, completionHandler: completionHandler)
    }
    
    func requestOwnerAvatar(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        //guard let comment = postNetworkManager.getComment(index: index) else { return }
        //postNetworkManager.requestOwnerAvatar(comment: comment, completionHandler: completionHandler)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
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

protocol DetailsBuilderProtocol {

    func produceOwner(group: DispatchGroup)
    func produceImage(group: DispatchGroup)
    func produceDetails(group: DispatchGroup)
    func produceComments(group: DispatchGroup)
    func startProduction(completionHandler: @escaping (Result<Void, Error>) -> Void)
}

class DetailBuilder: DetailsBuilderProtocol {
    
    func startProduction(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.requestDetails(id: detailId) { [weak self] result in
            switch result {
            case .success(let details):
                self?.details = details
                completionHandler(.success(Void()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    

    private let repository: DetailsRepository
    private let detailId: String
    
    private var product: Post = .init()
    
    init(detailId: String, repository: DetailsRepository) {
        self.repository = repository
        self.detailId = detailId
    }
    
    private var details: PostDetails!

    func reset() {
        product = Post()
    }

    func produceOwner(group: DispatchGroup) {
        product.owner = .init(realName: details.owner?.realName, username: details.owner?.username, location: details.owner?.location)
        
        repository.requestBuddyicon(post: details, group: group) { [weak self] result in
            switch result {
            case .success(let avatar):
                self?.product.owner?.avatar = avatar
            case .failure(let error):
                print("Avatar download failed: \(error)")
            }
        }
    }
    
    func produceImage(group: DispatchGroup) {
        repository.requestImage(post: details, group: group) { [weak self] result in
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
        
        repository.requestIsFavourite(group: group) { [weak self] result in
            switch result {
            case .success(let isFavourite):
                self?.product.isFavourite = isFavourite
            case .failure(let error):
                print("Favourite status download failed: \(error)")
            }
        }
    }
    
    func produceComments(group: DispatchGroup) {
        repository.requestComments(post: details, group: group) { [weak self] result in
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
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

class PostDirector {

    private var builder: DetailsBuilderProtocol?

    func update(builder: DetailsBuilderProtocol) {
        self.builder = builder
    }
    
    func startProduction(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        builder?.startProduction { result in
            switch result {
            case .success:
                self.buildPost {
                    completionHandler(.success(Void()))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    private func buildPost(completionHandler: @escaping () -> Void) {
        let group: DispatchGroup = .init()
        
        builder?.produceOwner(group: group)
        builder?.produceImage(group: group)
        builder?.produceDetails(group: group)
        builder?.produceComments(group: group)
        
        group.notify(queue: DispatchQueue.main) {
            completionHandler()
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

// MARK: - DetailsViewControllerDelegate

protocol DetailsViewControllerDelegate: AnyObject {
    func close()
}


protocol DetailsProtocol {
    
}
