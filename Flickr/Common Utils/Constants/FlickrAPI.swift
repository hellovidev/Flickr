//
//  FlickrAPI.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import Foundation

// MARK: - Flickr API private data
enum FlickrAPI: String {
    case consumerKey = "b01bf2906c64ed00736de70ad1238d5f"
    case secretKey = "d99635136dadab3c"
    case urlScheme = "flickrsdk"
}

enum RequestOAuthTokenInput {
    case consumerKey(_: String)
    case consumerSecret(_: String)
    case callbackScheme(_: String)
}

enum RequestOAuthTokenResponse {
    case oauthToken(_: String)
    case oauthTokenSecret(_: String)
    case oauthCallbackConfirmed(_: String)
}
