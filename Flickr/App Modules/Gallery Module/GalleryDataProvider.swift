//
//  GalleryDataProvider.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/19/21.
//

import Foundation

// MARK: - Error

private enum GalleryDataProviderError: Error {
    case emptyId
    case emptyAdditionalImageParameters
}

// MARK: - General Class `GalleryDataProvider`

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
    
    func fetchImage(index: Int, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        guard
            let id = galleryPhotos[index].id
        else {
            completionHandler(.failure(GalleryDataProviderError.emptyId))
            return
        }
        
        if let imageData = try? fileManager.fetch(forKey: id) {
            completionHandler(.success(imageData))
            return
        }
        
        guard
            let secret = galleryPhotos[index].secret,
            let server = galleryPhotos[index].server
        else {
            completionHandler(.failure(GalleryDataProviderError.emptyAdditionalImageParameters))
            return
        }
        
        remoteAPI.image(id: id, secret: secret, server: server) { result in
            completionHandler(result.map { [weak self] in
                try? self?.fileManager.justSave(fileData: $0, forKey: id)
                return $0
            })
        }
    }
    
    // MARK: - Save Methods
    
    func save(data: Data, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        do {
            let generatedId = UUID().uuidString
            try fileManager.justSave(fileData: data, forKey: generatedId)
            
            let localEntity = UserPhotoCoreEntity(context: self.localAPI.context)
            localEntity.id = generatedId
            localEntity.dateUploaded = String(Int(NSDate().timeIntervalSince1970))
            try localAPI.save()
            
            let domainEntity = UserPhoto(localEntity)
            galleryPhotos.insert(domainEntity, at: 0)
            
            DispatchQueue.main.async {
                completionHandler(.success(()))
            }
            
            remoteAPI.uploadImage(data) { [weak self] result in
                switch result {
                case .success(let uploadPhotoId):
                    self?.configure(updatedId: uploadPhotoId, previousId: generatedId, localEntity: localEntity) { result in
                        switch result {
                        case .success:
                            print("Uploaded photo configuration complete.")
                        case .failure(let error):
                            print("Configure uploaded photo error.", error)
                        }
                    }
                case .failure(let error):
                    print("Upload saved photo error.", error)
                }
            }
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    // MARK: - Delete Methods
    
    func detele(index: Int, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        guard
            let id = galleryPhotos[index].id
        else {
            completionHandler(.failure(GalleryDataProviderError.emptyId))
            return
        }
        
        remoteAPI.deletePhotoById(id) { [weak self] result in
            switch result {
            case .success:
                self?.galleryPhotos.remove(at: index)
                try? self?.fileManager.delete(forKey: id)
                try? self?.localAPI.delete(id)
                completionHandler(.success(()))
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
    
    /// Function replace old information about user photo with server information.
    private func configure(updatedId: String, previousId: String, localEntity: UserPhotoCoreEntity, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var detailsEntity = PhotoDetailsEntity()
        
        dispatchGroup.enter()
        remoteAPI.getPhotoById(for: updatedId) { result in
            switch result {
            case .success(let details):
                detailsEntity = details
            case .failure(let error):
                print("Loading photo details error.", error)
                completionHandler(.failure(error))
                return
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            // Update `Gallery Photos`
            self?.galleryPhotos[0].id = detailsEntity.id
            self?.galleryPhotos[0].server = detailsEntity.server
            self?.galleryPhotos[0].farm = detailsEntity.farm
            self?.galleryPhotos[0].secret = detailsEntity.secret
            
            // Update local storage
            localEntity.id = detailsEntity.id
            localEntity.server = detailsEntity.server
            if let farm = detailsEntity.farm {
                localEntity.farm = Int32(farm)
            }
            localEntity.secret = detailsEntity.secret
            localEntity.dateUploaded = detailsEntity.dateUploaded
            
            do {
                try self?.localAPI.save()
                try self?.fileManager.rename(atKey: previousId, toKey: updatedId)
                completionHandler(.success(()))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
}
