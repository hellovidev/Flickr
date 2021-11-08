//
//  DomainEntity.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation
import CoreData

/**
 A base entity for all of domain entities. All domain entities should inherit from this `DomainBaseEntity`. The `NSManagedObjectID` property from the `MappingProtocol` protocol is defined in `DomainEntity`. So none of the model classes needs to provide this property.
*/

class DomainEntity: MappingProtocol {
    
    var objectID: NSManagedObjectID?
    
    required init() { }
    
}
