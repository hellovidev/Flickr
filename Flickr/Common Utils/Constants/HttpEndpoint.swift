//
//  HTTP.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.08.2021.
//

import Foundation

// MARK: - API URL requests
enum HttpEndpoint: String {
    
    case baseDomain = "https://www.flickr.com"
    case uploadDomain = "https://up.flickr.com/services/upload/"
    
    // MARK: - Request Path Type
    enum PathType: String {
        case requestTokenOAuth = "/services/oauth/request_token"
        case accessTokenOAuth = "/services/oauth/access_token"
        case authorizeOAuth = "/services/oauth/authorize"
        case requestREST = "/services/rest"
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
