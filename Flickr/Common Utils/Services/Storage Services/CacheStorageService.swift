//
//  CacheService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 17.09.2021.
//

import Foundation

// MARK: - CacheStorageServiceProtocol

protocol CacheStorageServiceProtocol {
    
    associatedtype KeyType
    
    associatedtype ObjectType
        
    func set(for object: ObjectType, with key: KeyType)
    
    func get(for key: KeyType) throws -> ObjectType
    
    func remove(for key: KeyType)
    
    func removeAll()
    
}

// MARK: - CacheStorageService

struct CacheStorageService: CacheStorageServiceProtocol {
    
    typealias KeyType = AnyObject
    
    typealias ObjectType = AnyObject
    
    private let storage: NSCache<AnyObject, AnyObject> = .init()
    
    func set(for object: AnyObject, with key: AnyObject) {
        storage.setObject(object, forKey: key)
    }
    
    func get(for key: AnyObject) throws -> AnyObject {
        guard let object = storage.object(forKey: key) else {
            throw StorageServiceError.nilObject(key: key)
        }
        return object
    }

    func remove(for key: AnyObject) {
        storage.removeObject(forKey: key)
    }
    
    func removeAll() {
        storage.removeAllObjects()
    }
    
}
