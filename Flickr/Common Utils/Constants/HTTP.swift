//
//  HTTP.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.08.2021.
//

import Foundation

// MARK: - API URL requests
enum HttpEndpoint {
    
    // MARK: - InternetProtocolType
    enum InternetProtocolType: String {
        case http = "http://"
        case https = "https://"
    }
    
    // MARK: - HostType
    enum HostType: String {
        case hostAPI = "www.flickr.com/"
    }
    
    // MARK: - PathType
    enum PathType: String {
        case requestTokenOAuth = "services/oauth/request_token"
        case accessTokenOAuth = "services/oauth/access_token"
        case authorizeOAuth = "services/oauth/authorize"
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
