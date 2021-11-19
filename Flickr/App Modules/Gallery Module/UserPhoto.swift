//
//  UserPhoto.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/19/21.
//

import Foundation

struct UserPhoto {
    var id: String?
    var farm: Int?
    var secret: String?
    var server: String?
    var dateUpload: String?
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
