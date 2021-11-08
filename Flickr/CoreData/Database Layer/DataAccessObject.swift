//
//  DataAccessObject.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation
import CoreData

/**
 `DataAccessObject` is the parent of all the data access object (DAO) classes. It has methods that can be performed on the `StorageContext`. It declares the `StorageContext` as a dependency. You can pass any implementation of `StorageContext` here, for example,`CoreDataStorageContext` or `RealmStorageContext`. `DataAccessObject` expects two types of entities: Domain and Database. `DomainEntity` should be of type `MappingProtocol` while `DatabaseEntity` should conform to protocol `DatabaseEntityProtocol`. These entities are required for mapping between domain and database entities.
*/

class DataAccessObject<DomainEntity: MappingProtocol, DatabaseEntity: DatabaseEntityProtocol & NSManagedObject> {
    
    private var storageContext: StorageContext?
    
    required init(storageContext: StorageContext) {
        self.storageContext = storageContext
    }
    
    func create() -> MappingProtocol? {
        let dbEntity: DatabaseEntity? = storageContext?.create(DatabaseEntity.self)
        return mapToDomain(dbEntity: dbEntity!)
    }
    
    func save<DomainEntity: MappingProtocol>(object: DomainEntity) throws {
        var dbEntity: DatabaseEntity?
        if object.objectID != nil {
            dbEntity = storageContext?.objectWithObjectId(objectId: object.objectID!)
        } else {
            dbEntity = storageContext?.create(DatabaseEntity.self)
        }
        
        Mapper.mapToDatabaseEntity(from: object, target: dbEntity!)
        try storageContext?.save(object: dbEntity!)
    }
    
    func saveAll<DomainEntity: MappingProtocol>(objects: [DomainEntity]) throws {
        for domainEntity in objects {
            try self.save(object: domainEntity)
        }
    }
    
    func update<DomainEntity: MappingProtocol>(object: DomainEntity) throws {
        if object.objectID != nil {
            let dbEntity: DatabaseEntity? = storageContext?.objectWithObjectId(objectId: object.objectID!)
            Mapper.mapToDatabaseEntity(from: object, target: dbEntity!)
            try storageContext?.update(object: dbEntity!)
        }
    }
    
    func delete<DomainEntity: MappingProtocol>(object: DomainEntity) throws {
        if object.objectID != nil {
            let dbEntity: DatabaseEntity? = storageContext?.objectWithObjectId(objectId: object.objectID!)
            try storageContext?.delete(object: dbEntity!)
        }
    }
    
    func deleteAll() throws {
        try storageContext?.deleteAll(DatabaseEntity.self)
    }
    
    func fetch(predicate: NSPredicate?, sorted: Sorted? = nil) -> [DomainEntity] {
        let dbEntities = storageContext?.fetch(DatabaseEntity.self, predicate: predicate, sorted: sorted) as? [DatabaseEntity]
        return mapToDomain(dbEntities: dbEntities)
    }
    
    private func mapToDomain<DatabaseEntity: DatabaseEntityProtocol>(dbEntity: DatabaseEntity) -> DomainEntity {
        var domainEntity = DomainEntity.init()
        Mapper.mapToDomainEntity(from: dbEntity, target: &domainEntity)
        return domainEntity
    }
    
    private func mapToDomain<DatabaseEntity: DatabaseEntityProtocol>(dbEntities: [DatabaseEntity]?) -> [DomainEntity] {
        var domainEntities = [DomainEntity]()
        for dbEntity in dbEntities! {
            domainEntities.append(mapToDomain(dbEntity: dbEntity))
        }
        return domainEntities
    }
    
}
