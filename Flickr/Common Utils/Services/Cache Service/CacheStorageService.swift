//
//  CacheService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 17.09.2021.
//

import Foundation

// MARK: - Cache Error

enum StorageError: Error {
    
    case nilObject(key: AnyObject)
    
}

extension StorageError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .nilObject(key: let key):
            return "Nil object for key \(key)"
        }
    }
    
}

// MARK: - Cache Protocol

protocol StorageServiceProtocol {
    
    associatedtype KeyType
    
    associatedtype ObjectType
    
    func set(for object: ObjectType, with key: KeyType) throws
    
    func get(for key: KeyType) throws -> ObjectType
    
    func remove(for key: KeyType)
    
    func removeAll()
    
}

// MARK: - Cache Service

struct CacheStorageService<Key, Object>: StorageServiceProtocol where Key: AnyObject, Object: AnyObject {
    
    typealias KeyType = Key
    
    typealias ObjectType = Object
    
    private let cacheStorage: NSCache<Key, Object> = .init()
    
    func set(for object: Object, with key: Key) {
        cacheStorage.setObject(object, forKey: key)
    }
    
    func get(for key: Key) throws -> Object {
        guard let object = cacheStorage.object(forKey: key) else {
            throw StorageError.nilObject(key: key)
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

struct UserDefaultsStorageService<Object>: StorageServiceProtocol where Object: Codable {
    
    typealias KeyType = String
    
    typealias ObjectType = Object
    
    private let defaultsStorage: UserDefaults = .standard
    
    func set(for object: Object, with key: String) throws {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            defaultsStorage.set(data, forKey: key)
        } catch {
            throw error
        }
    }
    
    func get(for key: String) throws -> Object {
        do {
            guard let data = defaultsStorage.data(forKey: key) else {
                throw StorageError.nilObject(key: key as NSString)
            }
            let decoder = JSONDecoder()
            let object = try decoder.decode(Object.self, from: data)
            return object
        } catch {
            throw error
        }
    }
    
    func remove(for key: String) {
        defaultsStorage.removeObject(forKey: key)
    }
    
    func removeAll() {
        guard let domain = Bundle.main.bundleIdentifier else { return }
        defaultsStorage.removePersistentDomain(forName: domain)
        defaultsStorage.synchronize()
    }
    
}
