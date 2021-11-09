//
//  CoreDataManager.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/8/21.
//

import UIKit
import CoreData

class CoreDataManager: DependencyProtocol {
    
    var context: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func save(object: PhotoDetailsEntity, image: Data? = nil, avatar: Data? = nil) {
        let dbEntity = PhotoDetailsCoreEntity(context: context)
        dbEntity.id = object.id
        dbEntity.title = object.title?.content
        dbEntity.descriptionContent = object.description?.content
        dbEntity.image = image
        dbEntity.ownerName = object.owner?.realName
        dbEntity.ownerUsername = object.owner?.username
        dbEntity.ownerLocation = object.owner?.location
        dbEntity.ownerAvatar = avatar
        dbEntity.publishedAt = object.dateUploaded
        
        do {
            try context.save()
        } catch {
            print("Save `PhotoDetailsCoreEntity` error:", error)
        }
    }
    
    typealias PhotoDetail = (details: PhotoDetailsEntity?, image: UIImage?, buddyicon: UIImage?)
    
    func fetchAll() -> [PhotoDetail] {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        
        do {
            let objects = try context.fetch(request)
            let output = outputMapping(objects: objects)
            return output
        } catch {
            print("Fetch all `PhotoDetailsCoreEntity` error:", error)
            return []
        }
    }
    
    func fetchById(id: String) -> PhotoDetail {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if let object = try context.fetch(request).first {
                let output = outputMapping(objects: [object])
                return output[0]
            }
        } catch {
            print("Fetch by id `PhotoDetailsCoreEntity` error:", error)
        }
        
        return (nil, nil, nil)
    }
    
    func fetchIDs() -> [String] {
        let request: NSFetchRequest<NSDictionary> = .init(entityName: "PhotoDetailsCoreEntity")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["id"]
        
        do {
            let objects: [NSDictionary] = try context.fetch(request)
            let output = objects.map {
                $0.value(forKey: "id") as! String
            }
            return output
        } catch {
            print("Fetch ids `PhotoDetailsCoreEntity` error:", error)
            return []
        }
    }
    
    func deleteAllData() {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        
        do {
            let objects = try context.fetch(request)
            
            objects.forEach {
                context.delete($0)
            }
            
            try context.save()
        } catch {
            print("Detele all data in `PhotoDetailsCoreEntity` error:", error)
        }
    }
    
    // MARK: - Mapping
    
    private func outputMapping(objects: [PhotoDetailsCoreEntity]) -> [PhotoDetail] {
        let output = objects.map { object -> PhotoDetail in
            let photo = PhotoDetailsEntity()
            photo.id = object.id
            photo.title = .init(content: object.title)
            photo.description = .init(content: object.descriptionContent)
            photo.owner = .init(nsid: nil, username: object.ownerUsername, realName: object.ownerName, location: object.ownerLocation)
            photo.dateUploaded = object.publishedAt
            
            var image: UIImage?
            if let imageData = object.image {
                image = UIImage(data: imageData)
            }
            
            var buddyicon: UIImage?
            if let buddyiconData = object.ownerAvatar {
                buddyicon = UIImage(data: buddyiconData)
            }
            
            return (photo, image, buddyicon)
        }
        
        return output
    }
    
}
