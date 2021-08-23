//
//  FlickrOAuthError.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 21.08.2021.
//

import Foundation

// MARK: - FlickrOAuthError

enum FlickrOAuthError: Error {
    case dataCanNotBeParsed
    case responseIsEmpty
    case dataIsEmpty
    case invalidSignature
    case serverInternalError
    case unexpected(code: Int)
}

// MARK: -  LocalizedError

extension FlickrOAuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataCanNotBeParsed:
            return "Response data can not be parsed."
        case .responseIsEmpty:
            return "Response from server is empty."
        case .dataIsEmpty:
            return "Data from server is empty."
        case .invalidSignature:
            return "Invalid 'HMAC-SHA1' signature."
        case .serverInternalError:
            return "Internal server error."
        case .unexpected(_):
            return "An unexpected error occurred."
        }
    }
    
}
