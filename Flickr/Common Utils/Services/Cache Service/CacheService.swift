//
//  CacheService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 17.09.2021.
//

import Foundation

// MARK: - Cache Error

enum CacheError: Error {
    
    case nilObject(key: AnyObject)
    
}

extension CacheError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .nilObject(key: let key):
            return "Nil object for key \(key)"
        }
    }
    
}

// MARK: - Cache Protocol

protocol CacheServiceProtocol {
    
    associatedtype KeyType
    
    associatedtype ObjectType
    
    func set(for object: ObjectType, with key: KeyType)
    
    func get(for key: KeyType) throws -> ObjectType
    
    func remove(for key: KeyType)
    
    func removeAll()
    
}

// MARK: - Cache Service

struct CacheService<Object, Key>: CacheServiceProtocol where Object: AnyObject, Key: AnyObject {
    
    typealias KeyType = Key
    
    typealias ObjectType = Object
    
    private let cacheStorage: NSCache<Key, Object> = .init()
    
    func set(for object: Object, with key: Key) {
        cacheStorage.setObject(object, forKey: key)
    }
    
    func get(for key: Key) throws -> Object {
        guard let object = cacheStorage.object(forKey: key) else {
            throw CacheError.nilObject(key: key)
        }
        return object
    }
    
    func remove(for key: Key) {
        cacheStorage.removeObject(forKey: key)
    }
    
    func removeAll() {
        cacheStorage.removeAllObjects()
    }
        
}
