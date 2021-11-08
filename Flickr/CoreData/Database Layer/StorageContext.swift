//
//  StorageContext.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation
import CoreData

/**
 `StorageContext` consists of generic database operations that are required with almost any database implementation.
 */

protocol StorageContext {
    
    func create<DatabaseEntity: DatabaseEntityProtocol>(_ model: DatabaseEntity.Type) -> DatabaseEntity?
    
    func save(object: DatabaseEntityProtocol) throws
    
    func saveAll(objects: [DatabaseEntityProtocol]) throws
    
    func update(object: DatabaseEntityProtocol) throws
    
    func delete(object: DatabaseEntityProtocol) throws
    
    func deleteAll(_ model: DatabaseEntityProtocol.Type) throws
    
    //func fetch(_ model: DatabaseEntityProtocol.Type, predicate: NSPredicate?, sorted: Sorted?) -> [DatabaseEntityProtocol]
    
    func fetch<T: NSManagedObject>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?) -> [T]
    
}

/**
 CoreData entities are identified by `NSManagedObjectID`; we’ll need this method when fetching existing objects by ID from the database.
 */

extension StorageContext {
    
    func objectWithObjectId<DatabaseEntity: DatabaseEntityProtocol>(objectId: NSManagedObjectID) -> DatabaseEntity? {
        return nil
    }
    
}
