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
    
    private let dataManager: HomeDataManager
    
    init(coordinator: HomeCoordinator, storage: HomeDataManager) {
        self.coordinator = coordinator
        self.router = .init()
        self.dataManager = storage
        
        self.router.addObserver { [weak self] router in
            self?.show(router)
        }
    }
    
    // MARK: - Variables Helpers
    
    var idsOfDomainEntities = [String]()
    
    let filters: [String] = ["50", "100", "200", "400"]
    
    private var page: Int = 1
    
    private var perPage: Int = 20
    
    private var dictionaryOfDomainEntities = [DomainPhotoDetails]()
    
    var elementCount: Int {
        dictionaryOfDomainEntities.count
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

    func refresh() {
        page = 1
        //idsOfDomainEntities.removeAll()
        //dataManager.refreshStorage()
    }
    
    func filter(by filterType: FilterType?, completionHandler: @escaping () -> Void) {
        guard let filterType = filterType else {
            perPage = 20
            return
        }
        
        switch filterType {
        case .per50:
            perPage = 50
        case .per100:
            perPage = 100
        case .per200:
            perPage = 200
        case .per400:
            perPage = 400
        }
    }
    
    // MARK: - Reuests Details
    
    func requestPhotoDetailsIds(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        dataManager.requestArrayPhotoDetailsIds(page: page, per: perPage) { [weak self] result in
            switch result {
            case .success(let ids):
                self?.page += 1
                self?.idsOfDomainEntities = ids.uniques
                completionHandler(.success(()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    
    
    func loadData(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        if dataManager.connection.isReachable {
            dataManager.requestArrayPhotoDetailsIds(page: page, per: perPage) { [weak self] result in
                switch result {
                case .success(let ids):
                    let uniqs = ids.uniques
                    if self?.page == 1 {
                        self?.idsOfDomainEntities = uniqs
                    } else {
                        self?.idsOfDomainEntities += uniqs
                        if let realUniqIds = self?.idsOfDomainEntities.uniques {
                            self?.idsOfDomainEntities = realUniqIds
                        }
                    }
                    self?.dataManager.loadOnlineData(page: self!.page, ids: uniqs) { arrayNetwork in
                        if arrayNetwork.isEmpty {
                            self?.dataManager.loadOfflineData { result in
                                switch result {
                                case .success(let arrayCoreData):
                                    self?.dictionaryOfDomainEntities = arrayCoreData
                                    completionHandler(.success(()))
                                case .failure(let error):
                                    completionHandler(.failure(error))
                                }
                            }
                        } else {
                            if self?.page == 1 {
                                self?.dictionaryOfDomainEntities = arrayNetwork
                            } else {
                                self?.dictionaryOfDomainEntities += arrayNetwork
                                if let realUniqObjects = self?.dictionaryOfDomainEntities.uniques {
                                    self?.dictionaryOfDomainEntities = realUniqObjects
                                }
                            }
                            self?.page += 1
                            completionHandler(.success(()))
                        }
                    }
                    
                case .failure(_):
                    self?.dataManager.loadOfflineData { result in
                        switch result {
                        case .success(let arrayCoreData):
                            self?.dictionaryOfDomainEntities = arrayCoreData
                            completionHandler(.success(()))
                        case .failure(let error):
                            completionHandler(.failure(error))
                        }
                    }
                }
            }
        } else {
            self.dataManager.loadOfflineData { result in
                switch result {
                case .success(let arrayCoreData):
                    self.dictionaryOfDomainEntities = arrayCoreData
                    completionHandler(.success(()))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    func requestPhotoDetailsCell(indexPath: IndexPath, completionHandler: @escaping (_ details: PhotoDetailsEntity?, _ buddyicon: UIImage?, _ image: UIImage?) -> Void) {
        let domainEntity = dictionaryOfDomainEntities[indexPath.row]
        
        var buddyicon: UIImage?
        var image: UIImage?
        
        if let imagePath = domainEntity.imagePath, let imageData = try? self.dataManager.imageDataManager.fetchImageData(filePath: imagePath) {
            image = UIImage(data: imageData)
        }
        
        if let buddyiconPath = domainEntity.buddyiconPath, let buddyiconData = try? self.dataManager.imageDataManager.fetchImageData(filePath: buddyiconPath) {
            buddyicon = UIImage(data: buddyiconData)
        }
        
        completionHandler(domainEntity.details, buddyicon, image)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
