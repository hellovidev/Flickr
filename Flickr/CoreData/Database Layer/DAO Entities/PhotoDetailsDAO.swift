//
//  PhotoDetailsDAO.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation

// MARK: - Example DAO Entity

//// Every subclass of `DataAccessObject` should provide the domain and database entity. In the case of StoryDAO the Domain entity is Story and the DBentity is StoryEntity. I prefer to create a different DAO for every entity/database table.
///
///
class PhotoDetailsDAO: DataAccessObject<PhotoDetails, PhotoDetailsCoreEntity> {
    
    func findById(id: String) -> PhotoDetails? {
        return super.fetch(predicate: NSPredicate(format: "id == %@", id)).last
    }
        
}
