//
//  CoreDataManager.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/8/21.
//

import CoreData

private enum CoreDataManagerError: Error {
    case objectDoesNotExists
    case emptyArray
}

public class CoreDataManager {
    
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Save Methods
    
    public func saveObject(object: DomainPhotoDetails) throws {
        _ = self.registerNewObject(object: object)
        
        try self.commitUnsavedChanges()
    }
    
    public func saveSetOfObjects(objects: [DomainPhotoDetails]) throws {
        if objects.isEmpty {
            throw CoreDataManagerError.emptyArray
        }
            
        objects.forEach {
            _ = self.registerNewObject(object: $0)
        }
        
        try self.commitUnsavedChanges()
    }
    
    // MARK: - Fetch Methods
    
    public func fetchObjectsIds() throws -> [String] {
        let request: NSFetchRequest<NSDictionary> = .init(entityName: "PhotoDetailsCoreEntity")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["id"]
        
        let dictionaries: [NSDictionary] = try context.fetch(request)
        
        var ids = [String]()
        for dictionary in dictionaries {
            if let id = dictionary.value(forKey: "id") as? String {
                ids.append(id)
            }
        }

        return ids
    }
    
    public func fetchObjectById(id: String) throws -> DomainPhotoDetails {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        guard let objectFromDatabase = try context.fetch(request).first else { throw CoreDataManagerError.objectDoesNotExists }
        let objectAsDomainVersion = self.mapDatabaseObjectToDomainVersion(object: objectFromDatabase)
        
        return objectAsDomainVersion
    }
    
    public func fetchSetOfObjects() throws -> [DomainPhotoDetails] {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        let objectsFromDatabase = try context.fetch(request)
        
        let objectsAsDomainVersion = objectsFromDatabase.map { object in
            self.mapDatabaseObjectToDomainVersion(object: object)
        }
        
        return objectsAsDomainVersion
    }
    
    // MARK: - Delete Methods
    
    public func clearDatabase() throws {
        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        let objects = try context.fetch(request)
        
        objects.forEach {
            context.delete($0)
        }
        
        try self.commitUnsavedChanges()
    }
    
    // MARK: - Helper
    
    private func commitUnsavedChanges() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    private func registerNewObject(object: DomainPhotoDetails) -> PhotoDetailsCoreEntity {
        let dbEntity = PhotoDetailsCoreEntity(context: context)
        
        // Register main object information
        dbEntity.id = object.details?.id
        dbEntity.title = object.details?.title?.content
        dbEntity.descriptionContent = object.details?.description?.content
        dbEntity.publishedAt = object.details?.dateUploaded
        dbEntity.imagePath = object.imagePath
        
        // Register owner object informatin
        dbEntity.ownerId = object.details?.owner?.nsid
        dbEntity.ownerName = object.details?.owner?.realName
        dbEntity.ownerUsername = object.details?.owner?.username
        dbEntity.ownerLocation = object.details?.owner?.location
        dbEntity.ownerAvatarPath = object.buddyiconPath
        
        return dbEntity
    }
    
    private func mapDatabaseObjectToDomainVersion(object: PhotoDetailsCoreEntity) -> DomainPhotoDetails {
        var details = PhotoDetailsEntity()
        details.id = object.id
        details.title = .init(content: object.title)
        details.description = .init(content: object.descriptionContent)
        details.owner = .init(nsid: object.ownerId, username: object.ownerUsername, realName: object.ownerName, location: object.ownerLocation)
        details.dateUploaded = object.publishedAt
        
        // Create result object
        let objectAsDomainVersion = DomainPhotoDetails(details: details, imagePath: object.imagePath, buddyiconPath: object.ownerAvatarPath)
        return objectAsDomainVersion
    }
    
}

extension CoreDataManager: DependencyProtocol {}
