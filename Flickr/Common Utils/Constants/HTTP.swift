//
//  HTTP.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.08.2021.
//

import Foundation

// MARK: - API URL requests
enum HttpEndpoint {
    
    // MARK: - PathType
    enum PathType: String {
        case requestTokenOAuth = "/services/oauth/request_token"
        case accessTokenOAuth = "/services/oauth/access_token"
    }
    
}

// MARK: - HTTP method types
enum HttpMethodType: String {
    case GET
    case POST
    case DELETE
    case PUT
    case PATCH
}
