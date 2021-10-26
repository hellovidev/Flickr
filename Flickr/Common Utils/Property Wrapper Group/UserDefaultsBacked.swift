//
//  UserDefaultsBacked.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.10.2021.
//

import Foundation

// MARK: - UserDefaultsBacked Wrapper

@propertyWrapper struct UserDefaultsBacked<Value: Codable> {
    
    private let key: String
    
    private let defaultValue: Value
    
    private let storage: UserDefaultsStorageService
    
    var wrappedValue: Value {
        get {
            let value = try? storage.get(for: Value.self, with: key) //value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.remove(for: key)
            } else {
                try? storage.set(for: newValue, with: key)
            }
        }
    }
    
    init(wrappedValue defaultValue: Value,
         key: String) {
        self.defaultValue = defaultValue
        self.key = key
        self.storage = .init()
    }
    
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    init(key: String) {
        self.init(wrappedValue: nil, key: key)
    }
}
