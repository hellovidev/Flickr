//
//  CoreDataContextProvider.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/20/21.
//

import CoreData

public class CoreDataContextProvider {
    
    private var persistentContainer: NSPersistentContainer
    
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    init(completionHandler: ((Error?) -> Void)? = nil) {
        persistentContainer = NSPersistentContainer(name: "FlickrDatabase")
        persistentContainer.loadPersistentStores() { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved load `CoreData` stack error: \(error)")
            }
            
            completionHandler?(error)
            
            print(String(describing: storeDescription.url)) //??
        }
    }
    
    /// Method creates a context for background work.
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
}
