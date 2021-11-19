//
//  CoreDataManager.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/8/21.
//

import CoreData

public enum CoreDataManagerError: Error {
    case objectDoesNotExists
    case emptyArray
}

public class CoreDataManager {
    
    private let fetchedResultsController: NSFetchedResultsController<PhotoDetailsCoreEntity>
    //private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        //self.context = context
        
        let fetchRequest: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Save Methods
    
    public func saveObject(object: PhotoDetailsEntity) throws {
        _ = self.registerNewObject(object: object, position: 0)
        
        try self.commitUnsavedChanges()
    }
    
    public func saveSetOfObjects(objects: [PhotoDetailsEntity]) throws {
        if objects.isEmpty {
            throw CoreDataManagerError.emptyArray
        }
        
        var position = 0
        for object in objects {
            _ = self.registerNewObject(object: object, position: position)
            position += 1
        }
        
        try self.commitUnsavedChanges()
    }
    
    // MARK: - Fetch Methods
    
    public func fetchObjectsIds() throws -> [String] {
        //        let request: NSFetchRequest<NSDictionary> = .init(entityName: "PhotoDetailsCoreEntity")
        //        request.resultType = .dictionaryResultType
        //        request.returnsDistinctResults = true
        //        request.propertiesToFetch = ["id"]
        
        guard let objects = fetchedResultsController.fetchedObjects else {
            fatalError()
        }
        
        var ids = [String]()
        for object in objects {
            if let id = object.id {
                ids.append(id)
            }
        }
        
        
        //        let dictionaries: [NSDictionary] = try context.fetch(request)
        //
        //        var ids = [String]()
        //        for dictionary in dictionaries {
        //            if let id = dictionary.value(forKey: "id") as? String {
        //                ids.append(id)
        //            }
        //        }
        
        return ids
    }
    
    public func fetchObjects() throws -> [PhotoDetailsEntity] {
        guard let objects = fetchedResultsController.fetchedObjects else { fatalError() }
        
        let objectsAsDomainVersion = objects.map { object in
            self.mapDatabaseObjectToDomainVersion(object: object)
        }
        
        return objectsAsDomainVersion
    }
    
    //    public func fetchObjectById(id: String) throws -> PhotoDetailsEntity {
    //        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
    //        request.predicate = NSPredicate(format: "id == %@", id)
    //        guard let objectFromDatabase = try context.fetch(request).first else { throw CoreDataManagerError.objectDoesNotExists }
    //        let objectAsDomainVersion = self.mapDatabaseObjectToDomainVersion(object: objectFromDatabase)
    //
    //        return objectAsDomainVersion
    //    }
    //
    //    public func fetchSetOfObjects() throws -> [PhotoDetailsEntity] {
    //        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
    //        let positionSort = NSSortDescriptor(key: "position", ascending: true)
    //
    //        request.sortDescriptors = [positionSort]
    //        let objectsFromDatabase = try context.fetch(request)
    //
    //        let objectsAsDomainVersion = objectsFromDatabase.map { object in
    //            self.mapDatabaseObjectToDomainVersion(object: object)
    //        }
    //
    //        return objectsAsDomainVersion
    //    }
    
    // MARK: - Delete Methods
    
    public func clearDatabase() throws {
        if let objects = fetchedResultsController.fetchedObjects {
            objects.forEach {
                fetchedResultsController.managedObjectContext.delete($0)
            }
        }
        
        try self.commitUnsavedChanges()
    }
    
    // MARK: - Helper
    
    private func commitUnsavedChanges() throws {
        if fetchedResultsController.managedObjectContext.hasChanges {
            try fetchedResultsController.managedObjectContext.save()
        }
    }
    
    private func registerNewObject(object: PhotoDetailsEntity, position: Int) -> PhotoDetailsCoreEntity {
        let dbEntity = PhotoDetailsCoreEntity(context: fetchedResultsController.managedObjectContext)
        dbEntity.position = Int32(position)
        
        // Register main object information
        dbEntity.id = object.id
        dbEntity.secret = object.secret
        dbEntity.server = object.server
        dbEntity.title = object.title?.content
        dbEntity.descriptionContent = object.description?.content
        dbEntity.publishedAt = object.dateUploaded
        
        // Register owner object informatin
        dbEntity.ownerId = object.owner?.nsid
        dbEntity.ownerIconFarm = Int32((object.owner?.iconFarm)!)
        dbEntity.ownerIconServer = object.owner?.iconServer
        dbEntity.ownerName = object.owner?.realName
        dbEntity.ownerUsername = object.owner?.username
        dbEntity.ownerLocation = object.owner?.location
        
        return dbEntity
    }
    
    private func mapDatabaseObjectToDomainVersion(object: PhotoDetailsCoreEntity) -> PhotoDetailsEntity {
        var objectAsDomainVersion = PhotoDetailsEntity()
        objectAsDomainVersion.id = object.id
        objectAsDomainVersion.secret = object.secret
        objectAsDomainVersion.server = object.server
        objectAsDomainVersion.title = .init(content: object.title)
        objectAsDomainVersion.description = .init(content: object.descriptionContent)
        objectAsDomainVersion.owner = .init(nsid: object.ownerId, username: object.ownerUsername, realName: object.ownerName, location: object.ownerLocation, iconServer: object.ownerIconServer, iconFarm: Int(object.ownerIconFarm))
        objectAsDomainVersion.dateUploaded = object.publishedAt
        
        return objectAsDomainVersion
    }
    
}

extension CoreDataManager: DependencyProtocol {}
