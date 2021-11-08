//
//  DatabaseManager.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/5/21.
//

import Foundation
import CoreData

/**
 `DatabaseManager` have created to initialize the required DAOs. We need to provide the `StorageContext` implementation while initializing the DAO classes. `StorageContext` is the dependency for `DatabaseManager` and should be set before calling any DAO. That way, you can change the `StorageContext` implementation at runtime. We can also provide a `StorageContext` with different configuration types, such as in-memory while running the test cases.
*/

class DatabaseManager {
    
    private var storageContext: StorageContext?
    
    private init() { }

    static var shared = DatabaseManager()
    
    lazy var photoDetailsDAO = PhotoDetailsDAO(storageContext: storageContextImplementation())
    
    static func setup(storageContext: StorageContext) {
        shared.storageContext = storageContext
    }
    
    private func storageContextImplementation() -> StorageContext {
        if self.storageContext != nil {
            return self.storageContext!
        }
        fatalError("You must call setup to configure the StoreContext before accessing any dao")
    }
    
}



// STEP 4 TESTING

//class StoryService {
//
//    func createStory(story: Story) {
//        do {
//            try DatabaseManager.shared.storyDao.save(object: story)
//        } catch {
//        }
//    }
//
//    func fetchStoryByStoryNumber(storyNumber: String) -> Story? {
//        do {
//            return try DatabaseManager.shared.storyDao.findById(storyNumber: storyNumber)
//        } catch {
//        }
//        return nil
//    }
//
//}
//



//public class DatabaseManager {
//    
//    private let container: NSPersistentContainer!
//    
//    private lazy var context: NSManagedObjectContext = {
//        return container.viewContext
//    }()
//    
//    init(container: NSPersistentContainer) {
//        self.container = container
//    }
//    
//    func save(object: PhotoDetailsEntity) {
//        context.perform {
//            let photoDetailsEntityCoreData = PhotoDetailsCoreEntity(context: self.context)
//            photoDetailsEntityCoreData.id = object.id
//            photoDetailsEntityCoreData.title = object.title?.content
//            photoDetailsEntityCoreData.server = object.server
//        }
//    }
//    
//    func retrive() {
//        let request: NSFetchRequest<PhotoDetailsCoreEntity> = PhotoDetailsCoreEntity.fetchRequest()
//        
//        let photoArray = try? context.fetch(request)
//        
//        print(photoArray)
//    }
//}
