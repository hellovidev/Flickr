//
//  CoreDataManager.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/8/21.
//

import CoreData

public class CoreDataManager {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Save Methods
    
    public func saveObject(object: DomainPhotoDetails) throws {
        registerNewObject(object: object)
        
        do {
            try self.commitUnsavedChanges()
        } catch {
            print("Save `PhotoDetailsCoreEntity` error.", error)
            throw error
        }
    }
    
    public func saveSetOfObjects(objects: [DomainPhotoDetails]) throws {
        objects.forEach {
            registerNewObject(object: $0)
        }
        
        do {
            try self.commitUnsavedChanges()
        } catch {
            print("Save `PhotoDetailsCoreEntity` array error.", error)
            throw error
        }
    }
    
    // MARK: - Fetch Methods
    
    public func fetchObjectsIds() throws -> [String] {
        let request: NSFetchRequest<NSDictionary> = .init(entityName: "PhotoDetailsCoreEntity")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["id"]
        
        do {
            let dictionaries: [NSDictionary] = try context.fetch(request)
            
            var ids = [String]()
            for dictionary in dictionaries {
                if let id = dictionary.value(forKey: "id") as? String {
                    ids.append(id)
                }
            }

            return ids
        } catch {
            print("Fetch ids of `PhotoDetailsCoreEntity` error.", error)
            throw error
        }
    }
    
    public func fetchObjectById(id: String) throws -> DomainPhotoDetails {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            guard let objectFromDatabase = try context.fetch(request).first else { throw NSError() }
            let objectAsDomainVersion = self.mapDatabaseObjectToDomainVersion(object: objectFromDatabase)
            return objectAsDomainVersion
        } catch {
            print("Fetch object `PhotoDetailsCoreEntity` by id error.", error)
            throw error
        }
    }
    
    public func fetchSetOfObjects() throws -> [DomainPhotoDetails] {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        
        do {
            let objectsFromDatabase = try context.fetch(request)
            let objectsAsDomainVersion = objectsFromDatabase.map { [unowned self] object in
                self.mapDatabaseObjectToDomainVersion(object: object)
            }
            return objectsAsDomainVersion
        } catch {
            print("Fetch set of `PhotoDetailsCoreEntity` error.", error)
            throw error
        }
    }
    
    // MARK: - Delete Methods
    
    public func clearDatabase() throws {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        
        do {
            let objects = try context.fetch(request)
            
            objects.forEach {
                context.delete($0)
            }
            
            try self.commitUnsavedChanges()
        } catch {
            print("Clear database of `PhotoDetailsCoreEntity` error.", error)
            throw error
        }
    }
    
    // MARK: - Helper
    
    private func commitUnsavedChanges() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Unresolved error!", error)
                throw error
            }
        }
    }
    
    private func registerNewObject(object: DomainPhotoDetails) {
        let dbEntity = PhotoDetailsCoreEntity(context: context)
        
        // Register main object information
        dbEntity.id = object.details?.id
        dbEntity.title = object.details?.title?.content
        dbEntity.descriptionContent = object.details?.description?.content
        dbEntity.publishedAt = object.details?.dateUploaded
        dbEntity.imagePath = object.imagePath
        
        // Register owner object informatin
        dbEntity.ownerName = object.details?.owner?.realName
        dbEntity.ownerUsername = object.details?.owner?.username
        dbEntity.ownerLocation = object.details?.owner?.location
        dbEntity.ownerAvatarPath = object.buddyiconPath
    }
    
    private func mapDatabaseObjectToDomainVersion(object: PhotoDetailsCoreEntity) -> DomainPhotoDetails {
        let details = PhotoDetailsEntity()
        details.id = object.id
        details.title = .init(content: object.title)
        details.description = .init(content: object.descriptionContent)
        details.owner = .init(nsid: nil, username: object.ownerUsername, realName: object.ownerName, location: object.ownerLocation)
        details.dateUploaded = object.publishedAt
        
        // Create result object
        let objectAsDomainVersion = DomainPhotoDetails(details: details, imagePath: object.imagePath, buddyiconPath: object.ownerAvatarPath)
        return objectAsDomainVersion
    }
    
}

extension CoreDataManager: DependencyProtocol {}
