//
//  CacheStorageService.swift
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

struct CacheStorageService<Key: AnyObject, Object: AnyObject>: CacheStorageServiceProtocol {
    
    typealias KeyType = Key
    
    typealias ObjectType = Object
    
    private let storage: NSCache<Key, Object> = .init()
    
    func set(for object: Object, with key: Key) {
        storage.setObject(object, forKey: key)
    }
    
    func get(for key: Key) throws -> Object {
        guard let object = storage.object(forKey: key) else {
            throw StorageServiceError.nilObject(key: key)
        }
        return object
    }
    
    func remove(for key: Key) {
        storage.removeObject(forKey: key)
        
    }
    
    func removeAll() {
        storage.removeAllObjects()
    }
    
}
