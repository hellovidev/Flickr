//
//  ConfigurationType.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation

/**
 The most common databases come with both a concrete and an in-memory implementation. Core Data has an in-memory type that can be used for unit testing. Enum `ConfigurationType` supports this need.
 */

public enum ConfigurationType {
    
    case basic(identifier: String)
    case memory(identifier: String?)
    
    func identifier() -> String? {
        switch self {
        case .basic(let identifier):
            return identifier
        case .memory(let identifier):
            return identifier
        }
    }
    
}
