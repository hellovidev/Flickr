//
//  Mapper.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation
import CoreData
import Runtime

/**
 All our database entities should implement the `DatabaseEntityProtocol` protocol. Similarly, all our domain entities should implement the `MappingProtocol` protocol.
 
 - Parameters:
 - objectID: We are working with Core Data and CoreData entities defined by `NSManagedObjectID`. This is required while mapping domain entities to database entities. You may not need it if you already have a custom ID for your entities, such as story number.
 */

protocol MappingProtocol {
    
    var objectID: NSManagedObjectID? { get set }
    
    init()
    
}

/**
 `Mapper` maps the entities from domain to database and vice versa.
*/

class Mapper {
    
    class func mapToDomainEntity<DatabaseEntity: DatabaseEntityProtocol, DomainEntity: MappingProtocol>(from dbEntity: DatabaseEntity, target domainEntity: inout DomainEntity) {
        let domainEntityInfo = try? typeInfo(of: DomainEntity.self)
        let managedObject: NSManagedObject? = dbEntity as? NSManagedObject
        let keys = managedObject?.entity.attributesByName.keys
        
        for dbEntityKey in keys! {
            let value = managedObject?.value(forKey: dbEntityKey)
            do {
                let domainProperty = try domainEntityInfo?.property(named: dbEntityKey)
                try domainProperty?.set(value: value as Any, on: &domainEntity)
            } catch {
                print(error.localizedDescription)
            }
        }
        domainEntity.objectID = managedObject?.objectID
    }
    
    class func mapToDatabaseEntity<DomainEntity: MappingProtocol, DatabaseEntity: DatabaseEntityProtocol>(from domainEntity: DomainEntity, target dbEntity: DatabaseEntity) {
        let managedObject: NSManagedObject? = dbEntity as? NSManagedObject
        let keys = managedObject?.entity.attributesByName.keys
        let domainEntityMirror = Mirror(reflecting: domainEntity)
        
        for dbEntityKey in keys! {
            for property in domainEntityMirror.children.enumerated() where
            property.element.label == dbEntityKey {
                let value = property.element.value as AnyObject
                if !value.isKind(of: NSNull.self) {
                    managedObject?.setValue(value, forKey: dbEntityKey)
                }
            }
        }
    }
    
}
