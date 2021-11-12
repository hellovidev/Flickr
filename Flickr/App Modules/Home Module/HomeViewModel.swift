//
//  HomeViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.09.2021.
//

import UIKit

// MARK: - HomeViewModel

class HomeViewModel {
    
    // MARK: - Main Variables
    
    private weak var coordinator: HomeCoordinator?
    
    private let router: Observable<HomeRoute>
    
    private let homeDataManager: HomeDataManager
    
    init(coordinator: HomeCoordinator, storage: HomeDataManager) {
        self.coordinator = coordinator
        self.router = .init()
        self.homeDataManager = storage
        
        self.router.addObserver { [weak self] router in
            self?.show(router)
        }
    }
    
    // MARK: - Variables Helpers
    
    let filters: [String] = ["50", "100", "200", "400"]
    
    private var page: Int = 1
    
    private var perPage: Int = 20
    
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
    
    func refresh() {
        page = 1
    }
    
    func filter(by filterType: FilterType?, completionHandler: @escaping () -> Void) {
        guard let filterType = filterType else {
            perPage = 20
            return
        }
        
        switch filterType {
        case .per50: perPage = 50
        case .per100: perPage = 100
        case .per200: perPage = 200
        case .per400: perPage = 400
        }
    }
    
    func loadData(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        loadOfflineData(completionHandler: { result in
            completionHandler(result.map {
                self.loadOnlineData { result in
                    switch result {
                    case .success():
                        self.waitOnlineData?()
                    case .failure(let error):
                        print(error)
                    }
                }
            })
        })
    }
    
    // MARK: - General Requests
    
    var currentObjects = [PhotoDetailsEntity]()
    var onlineSession = [PhotoDetailsEntity]()
    var currentIds = [String]()
    var waitOnlineData: (() -> Void)?
    
    func switchToOnlineData() {
        currentObjects = onlineSession
    }
    
    func loadOnlineData(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        homeDataManager.requestEntityIds(page: page, per: perPage) { [weak self] result in
            switch result {
            case .success(let pageIds):
                if self?.page == 1 {
                    self?.currentIds.removeAll()
                }
                
                var newIds = [String]()
                if let common = self?.currentIds.filter(pageIds.contains) {
                    newIds = pageIds.subtracting(common)
                }
                self?.currentIds += newIds
                
                self?.homeDataManager.loadOnlineData(page: self!.page, pageIds: newIds, completionHandler: { result in
                    switch result {
                    case .success(let onlineSession):
                        self?.onlineSession = onlineSession
                        self?.page += 1
                        completionHandler(.success(()))
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                })
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func loadOfflineData(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        homeDataManager.loadOfflineData() { [weak self] result in
            switch result {
            case .success(let offlineSession):
                self?.currentObjects = offlineSession
                completionHandler(.success(()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    // MARK: - Parts of Photo Request
    
    func requestCellDetails(indexPath: IndexPath, completionHandler: @escaping (Result<PhotoDetailsEntity, Error>) -> Void) {
        completionHandler(.success(self.currentObjects[indexPath.row]))
    }
    
    func requestCellImage(details: PhotoDetailsEntity, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard
            let id = details.id,
            let secret = details.secret,
            let server = details.server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        let uniqIdentifier = id + secret + server
        
        if let imageData = try? self.homeDataManager.imageDataManager.fetchImageData(forKey: uniqIdentifier) {
            if let image = UIImage(data: imageData) {
                completionHandler(.success(image))
                return
            }
        }
        
        homeDataManager.requestImage(id: id, secret: secret, server: server) { result in
            switch result {
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    completionHandler(.success(image))
                } else {
                    completionHandler(.failure(ImageError.couldNotInit))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func requestCellBuddyicon(details: PhotoDetailsEntity, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard
            let farm = details.owner?.iconFarm,
            let server = details.owner?.iconServer,
            let nsid = details.owner?.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        let uniqIdentifier = String(farm) + server + nsid
        
        if let buddyiconData = try? self.homeDataManager.imageDataManager.fetchImageData(forKey: uniqIdentifier) {
            if let buddyicon = UIImage(data: buddyiconData) {
                completionHandler(.success(buddyicon))
                return
            }
        }
        
        homeDataManager.requestBuddyicon(farm: farm, server: server, nsid: nsid) { result in
            switch result {
            case .success(let buddyiconData):
                if let buddyicon = UIImage(data: buddyiconData) {
                    completionHandler(.success(buddyicon))
                } else {
                    completionHandler(.failure(ImageError.couldNotInit))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

extension Array where Element: Equatable {
    func subtracting(_ array: Array<Element>) -> Array<Element> {
        self.filter { !array.contains($0) }
    }
}
