//
//  FlickrCoreDataManagerTests.swift
//  FlickrTests
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import XCTest
import CoreData
import Flickr

class FlickrCoreDataManagerTests: XCTestCase {
    
//    func test_save_entityArraySuccess() {
//        let sut = CoreDataManager(context: mockPersistentContainer.viewContext)
//        
//        var object = DomainPhotoDetails()
//        object.details = .init()
//        object.details?.id = UUID().uuidString
//        object.details?.owner?.nsid = UUID().uuidString
//        
//        object.imagePath = UUID().uuidString
//        object.buddyiconPath = UUID().uuidString
//        
//        var setOfbjects = [DomainPhotoDetails]()
//        
//        for _ in 1...5 {
//            setOfbjects.append(object)
//        }
//        
//        XCTAssertNoThrow(try sut.saveSetOfObjects(objects: setOfbjects))
//    }
    
    func test_save_entityArrayFailed() {
        let sut = CoreDataManager(context: mockPersistentContainer.viewContext)
        
        XCTAssertThrowsError(try sut.saveSetOfObjects(objects: []))
    }
    
//    func test_save_entity() {
//        let sut = CoreDataManager(context: mockPersistentContainer.viewContext)
//
//        var object = DomainPhotoDetails()
//        object.details = .init()
//        object.details?.id = UUID().uuidString
//        object.details?.owner?.nsid = UUID().uuidString
//
//        object.imagePath = UUID().uuidString
//        object.buddyiconPath = UUID().uuidString
//
//        XCTAssertNoThrow(try sut.saveObject(object: object))
//    }
    
    // MARK: - Core Data
    
    lazy var mockPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Database")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print(String(describing: storeDescription.url))
        })
        
        return container
    }()
    
}
