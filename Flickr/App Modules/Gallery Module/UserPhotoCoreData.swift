//
//  UserPhotoCoreData.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/19/21.
//

import CoreData

// MARK: - Error

public enum CoreDataError: Error {
    case isEmpty
    case objectDoesNotExists
}

// MARK: - General Class `UserPhotoCoreData`

public class UserPhotoCoreData: NSObject, NSFetchedResultsControllerDelegate {
    
    public let context: NSManagedObjectContext
    
    fileprivate lazy var fetchedResultscontroller: NSFetchedResultsController<UserPhotoCoreEntity> = { [weak self] in
        guard let this = self else {
            fatalError("lazy property has been called after object has been descructed")
        }
        
        let fetchRequest = UserPhotoCoreEntity.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "dateUploaded", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController<UserPhotoCoreEntity>(fetchRequest: fetchRequest, managedObjectContext: this.context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = this
        
        return controller
    }()
    
    public init(context: NSManagedObjectContext) {
        self.context = context
        
        super.init()
        
        do {
            try fetchedResultscontroller.performFetch()
        } catch {
            fatalError("Can't execute the controller’s fetch request")
        }
    }
    
    // MARK: - Save Methods
    
    public func save() throws {
        if fetchedResultscontroller.managedObjectContext.hasChanges {
            try fetchedResultscontroller.managedObjectContext.save()
        }
    }
    
    // MARK: - Fetch Methods
    
    public func fetchById(_ id: String) throws -> UserPhotoCoreEntity {
        guard
            let fetchedObjects = fetchedResultscontroller.fetchedObjects
        else {
            throw CoreDataError.isEmpty
        }
        
        guard
            let result = fetchedObjects.first(where: { $0.id == id })
        else {
            throw CoreDataError.objectDoesNotExists
        }
        
        return result
    }
    
    public func fetchFullBatch(completionHandler: @escaping (Result<[UserPhotoCoreEntity], Error>) -> Void) {
        guard
            let result = fetchedResultscontroller.fetchedObjects
        else {
            completionHandler(.failure(CoreDataError.isEmpty))
            return
        }
        
        completionHandler(.success(result))
    }
    
    // MARK: - Delete Methods
    
    public func deleteById(_ id: String) throws {
        guard
            let fetchedObjects = fetchedResultscontroller.fetchedObjects
        else {
            throw CoreDataError.isEmpty
        }
        
        for fetchedObject in fetchedObjects {
            if fetchedObject.id == id {
                fetchedResultscontroller.managedObjectContext.delete(fetchedObject)
                try save()
                break
            }
        }
    }
    
    public func deleteAll() throws {
        guard
            let fetchedObjects = fetchedResultscontroller.fetchedObjects
        else {
            throw CoreDataError.isEmpty
        }
        
        for fetchedObject in fetchedObjects {
            fetchedResultscontroller.managedObjectContext.delete(fetchedObject)
        }
        
        try save()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    public var contentDidChange: (() -> ())?
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Content will change")
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            contentDidChange?()
            print("Core Data using `insert` method")
        case .delete:
            print("Core Data using `delete` method")
        case .move:
            print("Core Data using `move` method")
        case .update:
            print("Core Data using `update` method")
        @unknown default:
            print("Unknown Core Data method")
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Content did change")
    }
    
    // MARK: - Deinit
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
