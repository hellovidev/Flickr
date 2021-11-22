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
    case galleryPhotosStorageDoesNotexists
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
    public var loadDataNeedUpdate: (() -> ())?
    
    public init(userId: String, network: Network, database: UserPhotoCoreData, fileManager: FileManagerAPI) {
        self.userId = userId
        self.remoteAPI = network
        self.localAPI = database
        self.fileManager = fileManager
    }
    
    // MARK: - Fetch Methods
    
    public func fetch(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        localAPI.fetchFullBatch { [weak self] result in
            switch result {
            case .success(let localBatch):
                // Find not upload elements and update them `dateUpload` to track right position if somebody delete or upload some elements from another device
                let needUploadEntities = localBatch.filter { $0.isUploaded == false }
                needUploadEntities.reversed().forEach {
                    $0.dateUploaded = String(NSDate().timeIntervalSince1970)
                }
                try? self?.localAPI.save()
                
                // Set entities from database to `galleryPhotos`
                var domainEntities = [UserPhoto]()
                for localElement in localBatch {
                    var result = UserPhoto(localElement)
                    for needUploadElement in needUploadEntities {
                        if localElement.id == needUploadElement.id {
                            result.dateUploaded = needUploadElement.dateUploaded
                        }
                    }
                    domainEntities.append(result)
                }
                
                self?.galleryPhotos = domainEntities
                
                // If entities from database haven't been upload try to do it
                for needUploadElement in needUploadEntities {
                    dispatchGroup.enter()
                    
                    if let id = needUploadElement.id,
                       let imageData = try? self?.fileManager.fetch(forKey: id) {
                        
                        // Upload attempt
                        self?.remoteAPI.uploadImage(imageData) { result in
                            switch result {
                            case .success(let uploadPhotoId):
                                
                                // When uploading completed with success update information in database and localy in `galleryPhotos`
                                self?.configure(updatedId: uploadPhotoId, previousId: id, localEntity: needUploadElement) { result in
                                    switch result {
                                    case .success:
                                        print("Uploaded photo configuration complete.")
                                    case .failure(let error):
                                        print("Configure uploaded photo error.", error)
                                    }
                                    dispatchGroup.leave()
                                }
                            case .failure(let error):
                                print("Upload saved photo error.", error)
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Fetch local data error", error)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            if let userId = self?.userId {
                self?.remoteAPI.getUserPhotos(for: userId) { result in
                    switch result {
                    case .success(let remoteBatch):
                        self?.synchronize(remoteBatch, completionHandler: { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    completionHandler(.success(()))
                                }
                            case .failure(let error):
                                print("Synchronizing user photos error.", error)
                                DispatchQueue.main.async {
                                    completionHandler(.failure(error))
                                }
                            }
                        })
                    case .failure(let error):
                        print("Loading user photos error.", error)
                        DispatchQueue.main.async {
                            completionHandler(.failure(error))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(.failure(GalleryDataProviderError.emptyId))
                }
            }
        }
    }
    
    public func fetchImage(index: Int, completionHandler: @escaping (Result<Data, Error>) -> Void) {
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
    
    public func save(data: Data, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        do {
            let generatedId = UUID().uuidString
            try fileManager.justSave(fileData: data, forKey: generatedId)
            
            let localEntity = UserPhotoCoreEntity(context: self.localAPI.context)
            localEntity.id = generatedId
            localEntity.isUploaded = false
            localEntity.dateUploaded = String(Int(NSDate().timeIntervalSince1970))
            
            try? localAPI.save()
            
            let domainEntity = UserPhoto(localEntity)
            galleryPhotos.insert(domainEntity, at: 0)
            
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
            
            DispatchQueue.main.async {
                completionHandler(.success(()))
            }
        } catch {
            DispatchQueue.main.async {
                completionHandler(.failure(error))
            }
        }
    }
    
    // MARK: - Delete Methods
    
    public func detele(index: Int, completionHandler: @escaping (Result<Void, Error>) -> Void) {
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
                try? self?.localAPI.deleteById(id)
                DispatchQueue.main.async {
                    completionHandler(.success(()))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Function synchronizing local and remote stores. Method returns `true` if after synchronizing local store updates and `false` if local and remote stores alredy similar.
    private func synchronize(_ remoteEnities: [PhotoEntity], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        do {
            let notUploaded = self.galleryPhotos.filter({ $0.isUploaded == false })
            let ids = notUploaded.map { object -> String in
                guard
                    let id = object.id
                else {
                    fatalError("\(GalleryDataProviderError.emptyId)")
                }
                
                return id
            }
            
            if notUploaded.isEmpty {
                try self.localAPI.deleteAll()
            } else {
                try self.localAPI.deleteAllExcept(ids: ids)
            }
            
            self.galleryPhotos = notUploaded + remoteEnities.map {
                return UserPhoto($0)
            }
            
            for remoteElement in remoteEnities {
                let localEntity = UserPhotoCoreEntity(context: self.localAPI.context)
                localEntity.id = remoteElement.id
                if let farm = remoteElement.farm {
                    localEntity.farm = Int32(farm)
                }
                localEntity.server = remoteElement.server
                localEntity.secret = remoteElement.secret
                localEntity.dateUploaded = remoteElement.dateUpload
                localEntity.isUploaded = true
            }
            
            try self.localAPI.save()
            completionHandler(.success(()))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    /// Function replace old information about user photo with server information.
    private func configure(updatedId: String, previousId: String, localEntity: UserPhotoCoreEntity, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var detailsEntity = PhotoDetailsEntity()
        
        // Pre configuration
        guard
            let index = galleryPhotos.firstIndex(where: { $0.id == previousId })
        else {
            completionHandler(.failure(GalleryDataProviderError.galleryPhotosStorageDoesNotexists))
            return
        }
        
        galleryPhotos[index].id = updatedId
        galleryPhotos[index].isUploaded = true
        
        localEntity.id = updatedId
        localEntity.dateUploaded = galleryPhotos[index].dateUploaded
        localEntity.isUploaded = true
        try? localAPI.save()
        try? fileManager.rename(atKey: previousId, toKey: updatedId)
        
        // Detail configuration
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
            self?.galleryPhotos[index].server = detailsEntity.server
            self?.galleryPhotos[index].farm = detailsEntity.farm
            self?.galleryPhotos[index].secret = detailsEntity.secret
            
            // Update local storage
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
    
    public var numberOfElements: Int {
        galleryPhotos.count
    }
    
    // MARK: - Deinit
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
