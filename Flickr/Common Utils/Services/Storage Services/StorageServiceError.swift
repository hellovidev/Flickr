//
//  StorageServiceError.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.09.2021.
//

import Foundation

// MARK: - StorageServiceError

/// Storage Service Error
/// - Note: Storage error provider
enum StorageServiceError: Error {
    
    /// Error for 'nil' object
    /// - key: Key of empty object
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
