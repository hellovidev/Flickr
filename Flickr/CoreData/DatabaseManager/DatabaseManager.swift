//
//  DatabaseManager.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/5/21.
//

import Foundation
import CoreData

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
