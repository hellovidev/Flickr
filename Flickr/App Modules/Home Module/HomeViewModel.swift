//
//  HomeViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.09.2021.
//

import UIKit

// MARK: - HomeViewModel

class HomeViewModel {
    
    private weak var coordinator: HomeCoordinator?
    
    private let router: Observable<HomeRoute>
    
    private let repository: HomeRepository
    
    let filters: [String] = ["50", "100", "200", "400"]
    
    init(coordinator: HomeCoordinator, network: NetworkService) {
        self.coordinator = coordinator
        self.repository = .init(network: network)
        self.router = .init()
        
        self.router.addObserver { [weak self] router in
            self?.show(router)
        }
    }
    
    private enum HomeRoute {
        case openPost(id: String)
    }
    
    private func show(_ router: HomeRoute) {
        switch router {
        case .openPost(id: let id):
            coordinator?.redirectDetails(id: id)
        }
    }
    
    func openDetails(id: String) {
        router.send(.openPost(id: id))
    }
    
    var numberOfIds: Int {
        repository.idsCount
    }
    
    func refresh() {
        repository.refresh()
    }
    
    func filter(by filterType: FilterType?, completionHandler: @escaping () -> Void) {
        repository.filter(by: filterType, completionHandler: completionHandler)
    }
    
    func requestPhotosId(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.requestPhotosId(completionHandler: completionHandler)
    }
    
    func requestPhotoDetailsCell(indexPath: IndexPath, completionHandler: @escaping (_ details: PhotoDetailsEntity?, _ buddyicon: UIImage?, _ image: UIImage?) -> Void) {
        let group = DispatchGroup()
        
        var details: PhotoDetailsEntity?
        var buddyicon: UIImage?
        var image: UIImage?
        
        repository.requestPhotoDetails(position: indexPath.row, group: group) { [weak self] result in
            switch result {
            case .success(let photoDetails):
                details = photoDetails
                
                self?.requestImagesOfPhotoDetails(details: photoDetails, group: group) { avatar, photo in
                    buddyicon = avatar
                    image = photo
                    
                    DispatchQueue.main.async {
                        completionHandler(details, buddyicon, image)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(details, buddyicon, image)
                }
                print("Download photo details cell in \(#function) has error: \(error)")
            }
        }
    }
    
    private func requestImagesOfPhotoDetails(details: PhotoDetailsEntity, group: DispatchGroup, completionHandler: @escaping (_ avatar: UIImage?, _ photo: UIImage?) -> Void) {
        var avatar: UIImage?
        var photo: UIImage?
        
        repository.requestBuddyicon(post: details, group: group) { result in
            switch result {
            case .success(let image):
                avatar = image
            case .failure(let error):
                print("Download buddyicon error: \(error)")
            }
        }
        
        repository.requestImage(post: details, group: group) { result in
            switch result {
            case .success(let image):
                photo = image
            case .failure(let error):
                print("Download image error: \(error)")
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completionHandler(avatar, photo)
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
