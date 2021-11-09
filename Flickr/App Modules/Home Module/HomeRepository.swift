//
//  HomeNetworkManager.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.09.2021.
//

import CoreData
import UIKit

// MARK: - HomeRepository

class HomeRepository {
    
    private var storage: StorageService!
    
    private var ids = [String]()
    private var page: Int = 1
    private var perPage: Int = 20
    
    //private var posts: [PhotoDetailsEntity] = .init()
    
    init(storage: StorageService) {
        self.storage = storage
    }
    
    var idsCount: Int {
        ids.count
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
    
    func refresh() {
        page = 1
        ids.removeAll()
        storage.refreshStorage()
    }
    
    func requestPhotoDetailsIds(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        storage.requestArrayPhotoDetailsIds(page: page, per: perPage) { [weak self] result in
            switch result {
            case .success(let ids):
                self?.page += 1
                self?.ids = ids.uniques
                completionHandler(.success(()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func request(position: Int, completionHandler: @escaping (Result<DomainPhotoDetails, Error>) -> Void) {
        storage.requestPhotoDetailsById(id: ids[position], completionHandler: completionHandler)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
