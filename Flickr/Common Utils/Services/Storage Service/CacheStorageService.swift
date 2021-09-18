//
//  CacheService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 17.09.2021.
//

import Foundation

// MARK: - Cache Error

enum StorageServiceError: Error {
    
    case nilObject(key: AnyObject)
    
}

extension StorageServiceError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .nilObject(key: let key):
            return "Nil object for key \(key)"
        }
    }
    
}

// MARK: - Cache Protocol

protocol CacheStorageServiceProtocol {
    
    associatedtype KeyType
    
    associatedtype ObjectType
        
    func set(for object: ObjectType, with key: KeyType)
    
    func get(for key: KeyType) throws -> ObjectType
    
    func remove(for key: KeyType)
    
    func removeAll()
    
}

protocol LocalStorageServiceProtocol {
        
    func set<Object: Codable>(for object: Object, with key: String) throws
    
    func get<Object: Codable>(for type: Object.Type, with key: String) throws -> Object
    
    func remove(for key: String)
    
    func removeAll()
    
}

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

struct UserDefaultsStorageService: LocalStorageServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    func set<Object>(for object: Object, with key: String) throws where Object : Decodable, Object : Encodable {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            storage.set(data, forKey: key)
        } catch {
            throw error
        }
    }
    
    func get<Object>(for type: Object.Type = Object.self, with key: String) throws -> Object where Object : Decodable, Object : Encodable {
        do {
            guard let data = storage.data(forKey: key) else {
                throw StorageServiceError.nilObject(key: key as NSString)
            }
            let decoder = JSONDecoder()
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw error
        }
    }
    
    func remove(for key: String) {
        storage.removeObject(forKey: key)

    }
    
    func removeAll() {
        guard let domain = Bundle.main.bundleIdentifier else { return }
        storage.removePersistentDomain(forName: domain)
        storage.synchronize()
    }
    
}
