//
//  StorageService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import Foundation

//// MARK: - StorageProtocol
//
//protocol StorageProtocol {
//    func save<Value: Codable>(object: Value, with key: String) throws
//    func pull<Value: Codable>(for key: String, type: Value.Type) throws -> Value
//    func remove(for key: String)
//}
//
//// MARK: - Error
//
//enum Error: Error {
//    case dataNotFound
//}
//
//// MARK: - StorageService
//
//struct UserDefaultsStorageService: StorageProtocol {
//    
//    func save<Value: Codable>(object: Value, with key: String) throws {
//        do {
//            let encoder = JSONEncoder()
//            let data = try encoder.encode(object)
//            UserDefaults.standard.set(data, forKey: key)
//        } catch {
//            throw error
//        }
//    }
//    
//    func pull<Value: Codable>(for key: String, type: Value.Type = Value.self) throws -> Value {
//        do {
//            guard
//                let data = UserDefaults.standard.data(forKey: key)
//            else {
//                throw Error.dataNotFound
//            }
//            let decoder = JSONDecoder()
//            let object = try decoder.decode(type, from: data)
//            return object
//        } catch {
//            throw error
//        }
//    }
//    
//    func remove(for key: String) {
//        UserDefaults.standard.removeObject(forKey: key)
//
//    }
//    
//}
