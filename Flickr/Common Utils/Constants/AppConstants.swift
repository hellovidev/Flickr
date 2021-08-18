//
//  AppConstants.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import Foundation

// MARK: - App Constants
enum Constant {
    
}

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
    }
    
}
