//
//  FlickrTests.swift
//  FlickrTests
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import XCTest
import CoreData
@testable import Flickr

class FlickrDatabaseTests: XCTestCase {
    
    var database: CoreDataManager?

    func test_save_storyEntity() {
        database = .init(context: mockPersistentContainer.viewContext)
        
        database?.save(object: PhotoDetailsEntity())
        let objects = database?.fetchAll()
        XCTAssertNotNil(objects)
    }
    
    // MARK: - Helpers
    
    // MARK: - Core Data
    
    lazy var mockPersistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            print(String(describing: storeDescription.url))
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func mockSaveContext () {
        let context = mockPersistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
