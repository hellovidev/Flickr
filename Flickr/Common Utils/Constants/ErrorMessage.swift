//
//  ErrorMessage.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.08.2021.
//

import Foundation

// MARK: - Error Message

enum ErrorMessage: Error {
    case notFound
    case error(_ message: String)
}
