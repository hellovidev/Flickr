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
        
    init(coordinator: HomeCoordinator, storage: StorageService) {
        self.coordinator = coordinator
        self.repository = .init(storage: storage)
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
    
    func requestPhotoDetailsIds(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.requestPhotoDetailsIds(completionHandler: completionHandler)
    }
    
    func requestPhotoDetailsCell(indexPath: IndexPath, completionHandler: @escaping (_ details: PhotoDetailsEntity?, _ buddyicon: UIImage?, _ image: UIImage?) -> Void) {
        repository.request(position: indexPath.row) { result in
            switch result {
            case .success(let domainEntity):
                completionHandler(domainEntity.details, domainEntity.buddyicon, domainEntity.image)
            case .failure(let error):
                print("Load `PhotoDetails` error:", error)
                completionHandler(nil, nil, nil)
            }
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
