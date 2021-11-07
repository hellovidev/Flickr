//
//  DatabaseLayer.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation
import CoreData

// MARK: - Step #1: Prepare a Generic Database Layer

/**
 Any entity that needs to be saved to the database should implement the `DatabaseEntityProtocol` protocol.
 */

public protocol DatabaseEntityProtocol {
    init()
}

/**
 
 Sorted class is required to give a factor to sort the results on.
 
 - Parameters:
 - key: ...
 - ascending: ...
 
 */

public struct Sorted {
    var key: String
    var ascending: Bool = true
}

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
    
    func fetch(_ model: DatabaseEntityProtocol.Type, predicate: NSPredicate?, sorted: Sorted?) -> [DatabaseEntityProtocol]
    
}

/**
 The most common databases come with both a concrete and an in-memory implementation. Core Data has an in-memory type that can be used for unit testing. Enum `ConfigurationType` supports this need.
 */

public enum ConfigurationType {
    
    case basic(identifier: String)
    case memory(identifier: String?)
    
    func identifier() -> String? {
        switch self {
        case .basic(let identifier):
            return identifier
        case .memory(let identifier):
            return identifier
        }
    }
    
}

// MARK: - Step #2: Create a Specific Implementation of the Database Layer

/**
 CoreData entities are identified by `NSManagedObjectID`; we’ll need this method when fetching existing objects by ID from the database.
 */

extension StorageContext {
    
    func objectWithObjectId<DatabaseEntity: DatabaseEntityProtocol>(objectId: NSManagedObjectID) -> DatabaseEntity? {
        return nil
    }
    
}

/**
 `CoreDataStorageContext` is the implementation of the `StorageContext`.
 */

class CoreDataStorageContext: StorageContext {
    
    var context: NSManagedObjectContext?
    
    required init(configuration: ConfigurationType = .basic(identifier: "#xcdatamodel-name-here#")) {
        switch configuration {
        case .basic:
            initDatabase(modelName: configuration.identifier(), storeType: .inSQLiteStoreType)
        case .memory:
            initDatabase(storeType: .inMemoryStoreType)
        }
    }
    
    private func initDatabase(modelName: String? = nil, storeType: StoreType) {
        let coordinator = CoreDataStoreCoordinator.persistentStoreCoordinator(modelName: modelName, storeType: storeType)
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.context?.persistentStoreCoordinator = coordinator
    }
 
}

/**
 `CoreDataStorageContext` implements all the required methods from the `StorageContext` protocol.
 
 - Note: All the methods are expecting entities of the `DatabaseEntityProtocol` type.
 */

extension CoreDataStorageContext {
    
    func create<DatabaseEntity: DatabaseEntityProtocol>(_ model: DatabaseEntity.Type) -> DatabaseEntity? {
        let entityDescription =  NSEntityDescription.entity(forEntityName: String.init(describing: model.self), in: context!)
        let entity = NSManagedObject(entity: entityDescription!, insertInto: context)
        return entity as? DatabaseEntity
    }
    
    func save(object: DatabaseEntityProtocol) throws { }
    
    func saveAll(objects: [DatabaseEntityProtocol]) throws { }
    
    func update(object: DatabaseEntityProtocol) throws { }
    
    func delete(object: DatabaseEntityProtocol) throws { }
    
    func deleteAll(_ model: DatabaseEntityProtocol.Type) throws { }
    
    func fetch(_ model: DatabaseEntityProtocol.Type, predicate: NSPredicate?, sorted: Sorted?) -> [DatabaseEntityProtocol] {
        return []
    }
    
    func objectWithObjectId<DatabaseEntity: DatabaseEntityProtocol>(objectId: NSManagedObjectID) -> DatabaseEntity? {
        do {
            let result = try context!.existingObject(with: objectId)
            return result as? DatabaseEntity
        } catch {
            print("CoreData: Unresolved error \(error)")
        }
        
        return nil
    }
    
}

public enum StoreType: String {
    case inSQLiteStoreType
    case inMemoryStoreType
}

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

extension NSPersistentStoreCoordinator {
    
    /// NSPersistentStoreCoordinator error types
    public enum CoordinatorError: Error {
        /// .momd file not found
        case modelFileNotFound
        /// NSManagedObjectModel creation fail
        case modelCreationError
        /// Gettings document directory fail
        case storePathNotFound
    }
    
    /// Return NSPersistentStoreCoordinator object
    static func coordinator(modelName: String? = nil, storeType: StoreType) throws -> NSPersistentStoreCoordinator? {
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            throw CoordinatorError.modelFileNotFound
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoordinatorError.modelCreationError
        }
        
        let persistentContainer = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        if storeType == .inMemoryStoreType {
            try persistentContainer.configureInMemoryStore()
        } else {
            try persistentContainer.configureSQLiteStore(name: modelName!)
        }
        return persistentContainer
    }
    
}

extension NSPersistentStoreCoordinator {
    
    func configureSQLiteStore(name: String) throws {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            throw CoordinatorError.storePathNotFound
        }
        
        do {
            let url = documents.appendingPathComponent("\(name).sqlite")
            let options = [ NSMigratePersistentStoresAutomaticallyOption: true,
                                  NSInferMappingModelAutomaticallyOption: true ]
            try self.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            throw error
        }
    }
    
    func configureInMemoryStore() throws {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        self.addPersistentStore(with: description) { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
    }
    
}

/**
 All Core Data entities inherit the `NSManagedObject`, and by default, `NSManagedObject` does not implement the `DatabaseEntityProtocol` protocol. To mark the `NSManagedObject` as storable we need to conform it to the `DatabaseEntityProtocol`.
 */

extension NSManagedObject: DatabaseEntityProtocol { }

// MARK: - Step #3: Prepare a Mapping Layer for Database Implementation

/**
 We have seen before that all our database entities should implement the `DatabaseEntityProtocol` protocol. Similarly, all our domain entities should implement the `MappingProtocol` protocol.
 
 - Parameters:
 - objectID: We are working with Core Data and CoreData entities defined by `NSManagedObjectID`. This is required while mapping domain entities to database entities. You may not need it if you already have a custom ID for your entities, such as story number.
 */

protocol MappingProtocol {
    
    var objectID: NSManagedObjectID? { get set }
    
    init()
    
}

/**
 A base entity for all of domain entities. All domain entities should inherit from this `DomainBaseEntity`. The `NSManagedObjectID` property from the `MappingProtocol` protocol is defined in `DomainEntity`. So none of the model classes needs to provide this property.
*/

class DomainEntity: MappingProtocol {
    
    var objectID: NSManagedObjectID?
    
    required init() { }
    
}

/**
 `DataAccessObject` is the parent of all the data access object (DAO) classes. It has methods that can be performed on the `StorageContext`. It declares the `StorageContext` as a dependency. You can pass any implementation of `StorageContext` here, for example,`CoreDataStorageContext` or `RealmStorageContext`. `DataAccessObject` expects two types of entities: Domain and Database. `DomainEntity` should be of type `MappingProtocol` while `DatabaseEntity` should conform to protocol `DatabaseEntityProtocol`. These entities are required for mapping between domain and database entities.
*/

class DataAccessObject<DomainEntity: MappingProtocol, DatabaseEntity: DatabaseEntityProtocol> {
    
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

/**
 `Mapper` maps the entities from domain to database and vice versa.
*/

import Runtime

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

/**
 `DatabaseManager` have created to initialize the required DAOs. We need to provide the `StorageContext` implementation while initializing the DAO classes. `StorageContext` is the dependency for `DatabaseManager` and should be set before calling any DAO. That way, you can change the `StorageContext` implementation at runtime. We can also provide a `StorageContext` with different configuration types, such as in-memory while running the test cases.
*/

class DatabaseManager {
    
    private var storageContext: StorageContext?
    
    private init() { }

    static var shared = DatabaseManager()
    
    lazy var storyDao = StoryDao(storageContext: storageContextImplementation())
    lazy var anyOtherDao = AnyOtherDao(storageContext: storageContextImplementation())
    
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



///The ideal place to provide the StorageContext implementation is at the start of the app. However, it can be changed depending on your needs.



// STEP 4 TESTING

class StoryService {
    
    func createStory(story: Story) {
        do {
            try DatabaseManager.shared.storyDao.save(object: story)
        } catch {
        }
    }
    
    func fetchStoryByStoryNumber(storyNumber: String) -> Story? {
        do {
            return try DatabaseManager.shared.storyDao.findById(storyNumber: storyNumber)
        } catch {
        }
        return nil
    }
    
}










// MARK: - Example Database Entity

////This is what a sample StoryEntity looks like. Remember that StoryEntity is a DBEntity, i.e. it can be persisted to the DB.
///

public class StoryEntity: NSManagedObject {
    
}

extension StoryEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryEntity> {
        return NSFetchRequest<StoryEntity>(entityName: "StoryEntity")
    }
    
    @NSManaged public var storyNumber: String?
    @NSManaged public var title: String?
    
}


// MARK: - Example Domain Entity

class Story: DomainEntity, Codable {
    var storyNumber: String?
    var title: String?
}


// MARK: - Example DAO Entity

//// Every subclass of `DataAccessObject` should provide the domain and database entity. In the case of StoryDAO the Domain entity is Story and the DBentity is StoryEntity. I prefer to create a different DAO for every entity/database table.
///
///
class StoryDAO: DataAccessObject<Story, StoryEntity> {
    
    func findById(storyNumber: String) -> Story? {
        return super.fetch(predicate: NSPredicate(format: "storyNumber = %" + storyNumber)).last
    }
    
}
