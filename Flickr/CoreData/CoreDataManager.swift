//
//  CoreDataManager.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/8/21.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager: DependencyProtocol {
    
    var context: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func save(object: PhotoDetailsEntity, image: Data, avatar: Data) {
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
            print(error)
        }
    }
    
    typealias PhotoDetail = (details: PhotoDetailsEntity?, image: UIImage?, buddyicon: UIImage?)
    
    func fetchAll() -> [PhotoDetail] {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        
        do {
            let objects = try context.fetch(request)
            let output = outputMapping(objects: objects)
            print(output)
            return output
        } catch {
            print(error)
            return []
        }
    }
    
    func fetchByID(id: String) -> PhotoDetail? {
        let fetchRequest: NSFetchRequest<PhotoDetailsCoreEntity>
        fetchRequest = PhotoDetailsCoreEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        
        do {
            let object = try context.fetch(fetchRequest).first
            let output = outputMapping(objects: [object!])
            print(output)
            return output.first
        } catch {
            print(error)
            return nil
        }
    }
    
    func fetchIDs() -> [String] {
        let request: NSFetchRequest<NSDictionary> = .init(entityName: "PhotoDetailsCoreEntity")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["id"]
        
        do {
            let objects: [NSDictionary] = try context.fetch(request)
            let output = objects.map { dict -> String in
                dict.value(forKey: "id") as! String
            }
            print(output)
            return output
        } catch {
            print(error)
            return []
        }
    }
    
    private func outputMapping(objects: [PhotoDetailsCoreEntity]) -> [PhotoDetail] {
        let output = objects.map { object -> PhotoDetail in
            let photo = PhotoDetailsEntity()
            photo.id = object.id
            photo.title = .init(content: object.title)
            photo.description = .init(content: object.descriptionContent)
            photo.owner = .init(nsid: nil, username: object.ownerUsername, realName: object.ownerName, location: object.ownerLocation)
            photo.dateUploaded = object.publishedAt
            let image = UIImage(data: object.image!, scale: 1)
            let buddyicon = UIImage(data: object.ownerAvatar!)
            return (photo, image, buddyicon)
        }
        
        return output
    }
    
    private func inputMapping() {
        
    }
    
    func deleteAllData() {
        let fetchRequest: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()//<NSFetchRequestResult> = .init()

        do {
            let results = try context.fetch(fetchRequest)
            results.forEach {
                context.delete($0)
            }
            try context.save()
//            for object in results {
//                guard let objectData = object as? NSManagedObject else { continue }
//                context.delete(objectData)
//            }
        } catch let error {
            print("Detele all data in `PhotoDetailsCoreEntity` error :", error)
        }
    }
    
}
