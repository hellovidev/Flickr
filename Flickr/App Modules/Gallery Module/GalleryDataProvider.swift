//
//  GalleryDataProvider.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/19/21.
//

import Foundation

public class GalleryDataProvider {
    
    // MARK: - Services
    
    private let userId: String
    private let remoteAPI: Network
    private let localAPI: UserPhotoCoreData
    private let fileManager: FileManagerAPI
    
    // MARK: - Variables
    
    private var galleryPhotos = [UserPhoto]()
    public var loadDataNeedUpdate: (() -> Void)?
    
    public init(userId: String, network: Network, database: UserPhotoCoreData, fileManager: FileManagerAPI) {
        self.userId = userId
        self.remoteAPI = network
        self.localAPI = database
        self.fileManager = fileManager
    }
    
    // MARK: - Fetch Methods+
    
    public func fetch(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        localAPI.fetchFullBatch { [weak self] result in
            switch result {
            case .success(let localBatch):
                let domainEntities = localBatch.map {
                    return UserPhoto($0)
                }
                self?.galleryPhotos = domainEntities
                DispatchQueue.main.async {
                    completionHandler(.success(()))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            if let userId = self?.userId {
                self?.remoteAPI.getUserPhotos(for: userId) { result in
                    switch result {
                    case .success(let remoteBatch):
                        if let isNeedUpdate = self?.synchronize(remoteBatch) {
                            if isNeedUpdate {
                                self?.loadDataNeedUpdate?()
                            }
                        }
                    case .failure(let error):
                        print("Loading user photos error.", error)
                    }
                }
            }
        }
    }
    
    // MARK: - Save Methods
    
    func save(data: Data, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    // MARK: - Delete Methods
    
    func detele(index: Int, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        guard
            let id = galleryPhotos[index].id
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        remoteAPI.deletePhotoById(id) { [weak self] result in
            switch result {
            case .success:
                self?.galleryPhotos.remove(at: index)
                try? self?.fileManager.delete(forKey: id)
                try? self?.localAPI.delete(id)
                completionHandler(.success(Void()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Function synchronizing local and remote stores. Method returns `true` if after synchronizing local store updates and `false` if local and remote stores alredy similar.
    private func synchronize(_ array: [PhotoEntity]) -> Bool {
        return false
    }
    
}
