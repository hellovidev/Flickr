//
//  FlickrOAuthError.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 21.08.2021.
//

import Foundation

// MARK: - FlickrOAuthError

enum FlickrOAuthError: Error {
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
        case .responseIsEmpty:
            return NSLocalizedString("Response from server is empty.",comment: "FlickrOAuthError Error")
        case .dataIsEmpty:
            return NSLocalizedString("Data from server is empty.",comment: "FlickrOAuthError Error")
        case .invalidSignature:
            return NSLocalizedString("Invalid 'HMAC-SHA1' signature.",comment: "FlickrOAuthError Error")
        case .serverInternalError:
            return NSLocalizedString("Internal server error.",comment: "FlickrOAuthError Error")
        case .unexpected(_):
            return NSLocalizedString("An unexpected error occurred.",comment: "FlickrOAuthError Error")
        }
    }
    
}
