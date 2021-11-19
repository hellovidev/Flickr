//
//  GalleryDataProvider.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/19/21.
//

import Foundation

public class GalleryDataProvider {
    
    // MARK: - Services
    
    private let remoteAPI: Network
    private let localAPI: UserPhotoCoreData
    
    // MARK: - Variables
    
    private var galleryPhotos = [PhotoEntity]()
    
    init(userId: String, network: Network, database: UserPhotoCoreData) {
        self.remoteAPI = network
        self.localAPI = database
    }
    
    // MARK: - Fetch Methods+
    
    func fetch(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        localAPI.fetchFullBatch { [weak self] result in
            switch result {
            case .success(let batch):
                self?.galleryPhotos
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    
    
    // MARK: - Save Methods
    
    func save(data: Data, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    // MARK: - Delete Methods
    
    func detele(id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    // MARK: - Helpers
    
}

public class UserPhotoCovertor {
    
    public func toUserPhotoCoreEntity() -> UserPhotoCoreEntity {
        
    }
    
    public func toPhotoEntity(_ coreDataObject: UserPhotoCoreEntity) -> PhotoEntity {
        let photoEntity = PhotoEntity(id: coreDataObject.id, title: <#T##String?#>, owner: <#T##String?#>, isPublic: <#T##Int?#>, isFriend: <#T##Int?#>, secret: coreDataObject.id, server: <#T##String?#>, farm: <#T##Int?#>, isFamily: <#T##Int?#>)
        return
    }
    
}

struct UserPhoto {
    var id: String
    var farm: Int
    var secret: String
    var server: String
    var dateUpload: String
}

extension UserPhoto {
    init(_ coreDataEntity: UserPhotoCoreEntity) {
        if let id = coreDataEntity.id {
            self.id = id
        }
        
        if let farm = coreDataEntity.farm {
            self.farm = Int(farm)
        }
        
        if let secret = coreDataEntity.secret {
            self.secret = secret
        }
        
        if let server = coreDataEntity.server {
            self.server = server
        }
        
        if let dateUpload = coreDataEntity.dateUpload {
            self.dateUpload = dateUpload
        }
    }
    
    init(_ remoteEntity: PhotoEntity) {
        if let id = remoteEntity.id {
            self.id = id
        }
        
        if let farm = remoteEntity.farm {
            self.farm = Int(farm)
        }
        
        if let secret = remoteEntity.secret {
            self.secret = secret
        }
        
        if let server = remoteEntity.server {
            self.server = server
        }
                
        if let dateUpload = remoteEntity.dateUpload {
            self.dateUpload = dateUpload
        }
    }
    
    
}
