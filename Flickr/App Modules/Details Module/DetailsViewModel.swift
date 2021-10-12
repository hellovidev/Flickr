//
//  DetailsViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

class DetailsViewModel {
    
    private let repository: DetailsRepository
    
    private weak var coordinator: HomeCoordinator?

    weak var delegate: DetailsViewControllerDelegate?
    
    init(coordinator: HomeCoordinator, id: String, network: NetworkService) {
        self.coordinator = coordinator
        self.repository = .init(id: id, network: network)
    }
    
    func close() {
        coordinator?.close()
    }
    
    func refresh() {
        repository.removeAllComments()
    }
    
    func requestAddFavourite(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.requestAddFavourite(completionHandler: completionHandler)
    }
    
    func requestRemoveFavourite(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.requestRemoveFavourite(completionHandler: completionHandler)
    }
    
    var isFavourite: Bool {
        repository.getIsFavourite()
    }
    
    var numberOfComments: Int {
        repository.numberOfComments()
    }

    func requestDetails(completionHandler: @escaping (Result<Post, Error>) -> Void) {
        repository.requestPreparatoryDataOfDetails { [weak self] result in
            switch result {
            case .success:
                self?.collectPartsOfDetails {
                    if let details = self?.repository.retrieveDetails() {
                        completionHandler(.success(details))
                        return
                    }
                    completionHandler(.failure(NetworkManagerError.nilResponseData))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func collectPartsOfDetails(completionHandler: @escaping () -> Void) {
        let group: DispatchGroup = .init()
                
        repository.collectDetailsOwnerAvatar(group: group)
        repository.collectDetailsImage(group: group)
        repository.collectIsFavourite(group: group)
        repository.collectDetailsComments(group: group)
        
        group.notify(queue: DispatchQueue.main) {
            completionHandler()
        }
    }
        
    func commentForRowAt(index: Int, completionHandler: @escaping (CommentProtocol) -> Void) {
        var comment: PhotoComment = repository.retrieveCommentAt(index: index) as! PhotoComment
        
        requestCommentOwnerAvatar(index: index) { result in
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
        
    private func requestCommentOwnerAvatar(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard let comment = repository.retrieveCommentAt(index: index) else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        repository.requestCommentOwnerAvatar(comment: comment, completionHandler: completionHandler)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

// MARK: - DetailsViewControllerDelegate

protocol DetailsViewControllerDelegate: AnyObject {
    func close()
}
