//
//  StorageService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import Foundation

protocol StorageProtocol {
    static func save<Value: Codable>(object: Value, with key: String) throws
    static func pull<Value: Codable>(type: Value.Type, for key: String) throws -> Value
}

enum StorageError: Error {
    case dataNotFound
}

struct StorageService: StorageProtocol {
    
    static func save<Value: Codable>(object: Value, with key: String) throws {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            throw error
        }
    }
    
    static func pull<Value: Codable>(type: Value.Type, for key: String) throws -> Value {
        do {
            guard
                let data = UserDefaults.standard.data(forKey: key)
            else {
                throw StorageError.dataNotFound
            }
            let decoder = JSONDecoder()
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw error
        }
    }
    
    static func remove(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
}
