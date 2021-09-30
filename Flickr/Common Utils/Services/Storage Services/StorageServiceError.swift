//
//  StorageServiceError.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.09.2021.
//

import Foundation

// MARK: - StorageServiceError

enum StorageServiceError<Key>: Error {
    case nilObject(key: Key)
}

extension StorageServiceError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .nilObject(key: let key):
            return "Nil object for key \(key)"
        }
    }
    
}
