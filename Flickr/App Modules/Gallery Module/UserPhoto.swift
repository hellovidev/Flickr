//
//  UserPhoto.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/19/21.
//

import Foundation

protocol UserPhotoProtocol {
    var id: String? { get set }
}

struct UserPhoto: UserPhotoProtocol {
    var id: String?
    var farm: Int?
    var secret: String?
    var server: String?
    var dateUploaded: String?
    var isUploaded: Bool
}

extension UserPhoto {
    
    init(_ coreDataEntity: UserPhotoCoreEntity) {
        if let id = coreDataEntity.id {
            self.id = id
        }
        
        self.farm = Int(coreDataEntity.farm)
        
        if let secret = coreDataEntity.secret {
            self.secret = secret
        }
        
        if let server = coreDataEntity.server {
            self.server = server
        }
        
        if let dateUpload = coreDataEntity.dateUploaded {
            self.dateUploaded = dateUpload
        }
        
        self.isUploaded = coreDataEntity.isUploaded
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
            self.dateUploaded = dateUpload
        }
        
        self.isUploaded = true
    }
    
}
