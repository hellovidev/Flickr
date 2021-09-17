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
    
    func set(for object: AnyObject, with key: AnyObject)
    
    func get(for key: AnyObject) throws -> AnyObject
    
    func remove(for key: AnyObject)
    
    func removeAll()
    
}

// MARK: - Cache Service

struct CacheService: CacheServiceProtocol {
    
    private let cacheStorage: NSCache<AnyObject, AnyObject> = .init()
    
    func set(for object: AnyObject, with key: AnyObject) {
        cacheStorage.setObject(object, forKey: key)
    }
    
    func get(for key: AnyObject) throws -> AnyObject {
        guard let object = cacheStorage.object(forKey: key) else {
            throw CacheError.nilObject(key: key)
        }
        return object
    }
    
    func remove(for key: AnyObject) {
        cacheStorage.removeObject(forKey: key)
    }
    
    func removeAll() {
        cacheStorage.removeAllObjects()
    }
    
}
