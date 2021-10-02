//
//  UserDefaultsStorageService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.09.2021.
//

import Foundation

// MARK: - LocalStorageServiceProtocol

protocol LocalStorageServiceProtocol {
    
    func set<Object: Codable>(for object: Object, with key: String) throws
    
    func get<Object: Codable>(for type: Object.Type, with key: String) throws -> Object
    
    func remove(for key: String)
    
    func removeAll()
    
}

// MARK: - UserDefaultsStorageService

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
                throw StorageServiceError.nilObject(key: key)
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
