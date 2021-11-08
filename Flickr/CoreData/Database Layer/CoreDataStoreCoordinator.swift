//
//  CoreDataStoreCoordinator.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation
import CoreData

/**
 `CoreDataStoreCoordinator` is the class responsible for the initialization of the database and setting up all the prerequisites.
 */

class CoreDataStoreCoordinator {
    
    static func persistentStoreCoordinator(modelName: String? = nil, storeType: StoreType = .inSQLiteStoreType) -> NSPersistentStoreCoordinator? {
        do {
            return try NSPersistentStoreCoordinator.coordinator(modelName: modelName, storeType: storeType)
        } catch {
            print("CoreData: Unresolved error \(error)")
        }
        
        return nil
    }
    
}
