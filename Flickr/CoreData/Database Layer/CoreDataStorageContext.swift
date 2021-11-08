//
//  CoreDataStorageContext.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation
import CoreData

/**
 `CoreDataStorageContext` is the implementation of the `StorageContext`.
 */

class CoreDataStorageContext: StorageContext {
    
    var context: NSManagedObjectContext?
    
    required init(configuration: ConfigurationType = .basic(identifier: "#xcdatamodel-name-here#")) {
        switch configuration {
        case .basic:
            initDatabase(modelName: configuration.identifier(), storeType: .inSQLiteStoreType)
        case .memory:
            initDatabase(storeType: .inMemoryStoreType)
        }
    }
    
    private func initDatabase(modelName: String? = nil, storeType: StoreType) {
        let coordinator = CoreDataStoreCoordinator.persistentStoreCoordinator(modelName: modelName, storeType: storeType)
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.context?.persistentStoreCoordinator = coordinator
        
//        coordinator?.persistentStores.map {
//            print($0.url)
//        }
    }
 
}

/**
 `CoreDataStorageContext` implements all the required methods from the `StorageContext` protocol.
 
 - Note: All the methods are expecting entities of the `DatabaseEntityProtocol` type.
 */

extension CoreDataStorageContext {
    
    func create<DatabaseEntity: DatabaseEntityProtocol>(_ model: DatabaseEntity.Type) -> DatabaseEntity? {
        let entityDescription =  NSEntityDescription.entity(forEntityName: String.init(describing: model.self), in: context!)
        let entity = NSManagedObject(entity: entityDescription!, insertInto: context)
        return entity as? DatabaseEntity
    }
    
    func save(object: DatabaseEntityProtocol) throws {
        do {
            try context?.save()
        } catch {
            print("Unresolved error \(error)")
        }
    }
    
    func saveAll(objects: [DatabaseEntityProtocol]) throws { }
    
    func update(object: DatabaseEntityProtocol) throws { }
    
    func delete(object: DatabaseEntityProtocol) throws { }
    
    func deleteAll(_ model: DatabaseEntityProtocol.Type) throws { }
        
    func fetch(_ model: DatabaseEntityProtocol.Type, predicate: NSPredicate?, sorted: Sorted?) -> [DatabaseEntityProtocol] {
//        let fetchRequest: NSFetchRequest<model>
//
//        fetchRequest = Entity.fetchRequest()
//
//        fetchRequest.predicate = predicate
//        let objects = try context!.fetch(fetchRequest)
//
//        return objects
        return []
    }
    
    func fetch<T: NSManagedObject>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?) -> [T] {
        let fetchRequest = T.fetchRequest()
        do {
            fetchRequest.predicate = predicate
            guard let result = try context?.fetch(fetchRequest) as? [T] else { return [] }
            return result
        } catch {
            print(error)
        }
        
        return []
    }
    
    func objectWithObjectId<DatabaseEntity: DatabaseEntityProtocol>(objectId: NSManagedObjectID) -> DatabaseEntity? {
        do {
            let result = try context!.existingObject(with: objectId)
            return result as? DatabaseEntity
        } catch {
            print("CoreData: Unresolved error \(error)")
        }
        
        return nil
    }
    
}
