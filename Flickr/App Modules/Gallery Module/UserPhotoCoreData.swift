//
//  UserPhotoCoreData.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/19/21.
//

import CoreData

public class UserPhotoCoreData: NSObject, NSFetchedResultsControllerDelegate {
    
    let context: NSManagedObjectContext
    
    fileprivate lazy var fetchedResultscontroller: NSFetchedResultsController<UserPhotoCoreEntity> = { [weak self] in
        guard let this = self else {
            fatalError("lazy property has been called after object has been descructed")
        }
        
        guard let fetchRequest = UserPhotoCoreEntity.fetchRequest() as? NSFetchRequest<UserPhotoCoreEntity> else {
            fatalError("Can't set up NSFetchRequest")
        }
        
        let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController<UserPhotoCoreEntity>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = this
        
        return controller
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        super.init()
        
        do {
            try self.fetchedResultscontroller.performFetch()
        } catch {
            fatalError("Can't execute the controller’s fetch request")
        }
    }
    
//    func fetchById(_ id: String) throws -> UserPhotoCoreEntity {
//        let objects = try fetchAll()
//        guard let object = objects.first(where: {
//            ($0 as! UserPhotoCoreEntity).id == id
//        }) else { throw CoreDataManagerError.objectDoesNotExists }
//        return object
//    }
    
    func fetchFullBatch(completionHandler: @escaping (Result<[UserPhotoCoreEntity], Error>) -> Void) {
        guard
            let batch = fetchedResultscontroller.fetchedObjects
        else {
            completionHandler(.failure(CoreDataError.isEmpty))
            return
        }
        
        completionHandler(.success(batch))
    }
    
    func save() throws {
        if fetchedResultscontroller.managedObjectContext.hasChanges {
            try fetchedResultscontroller.managedObjectContext.save()
        }
    }
    
    func delete(_ id: String) throws {
        if let objects = fetchedResultscontroller.fetchedObjects {
            for object in objects {
                if (object as! UserPhotoCoreEntity).id == id {
                    fetchedResultscontroller.managedObjectContext.delete(object)
                    break
                }
            }
        }
                
        try save()
    }
        
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("will")
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("insert")
            didChange?()
        case .delete:
            print("delete")
        case .move:
            print("move")
        case .update:
            print("update")
        @unknown default:
            print("unknown")
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("did")
    }
    
    var didChange: (() -> ())?
    
}

public enum CoreDataError: Error {
    case isEmpty
    case objectDoesNotExists
}
