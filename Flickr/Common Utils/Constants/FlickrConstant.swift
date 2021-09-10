//
//  FlickrConstant.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import Foundation

// MARK: - Flickr Constants

enum FlickrConstant {
    
    enum URL: String {
        case base = "https://www.flickr.com"
        case upload = "https://up.flickr.com/services/upload/"
        case request = "https://www.flickr.com/services/rest"
        case signup = "https://identity.flickr.com/sign-up"
    }
    
    // MARK: - Flickr Methods Identifiers (Documentstion: https://www.flickr.com/services/api/)
    
    enum Method: String {
        // Profile screen
        case getProfile = "flickr.profile.getProfile"
        
        // Home screen
        case getHotTags = "flickr.tags.getHotList"
        case getRecentPosts = "flickr.photos.getRecent"
        case getPhotoInfo = "flickr.photos.getInfo"
        case getPhotoComments = "flickr.photos.comments.getList"
        case addPhotoComment = "flickr.photos.comments.addComment"
        case deletePhotoComment = "flickr.photos.comments.deleteComment"
        case addToFavorites = "flickr.favorites.add"
        case removeFromFavorites = "flickr.favorites.remove"
        case getFavorites = "flickr.favorites.getList"
        
        // Gallery screen
        case getUserPhotos = "flickr.people.getPhotos" // => "flickr.___.getUserPhotos"
        case deleteUserPhotoById = "flickr.photos.delete"
    }
    
    // MARK: - Private Keys
    
    /// Flickr OAuth1.0 private keys (https://www.flickr.com/services/api/misc.api_keys.html)
    /// - Parameter consumerKey: You must replace 'PUBLIC_API_KEY' with your valid public API key
    /// - Parameter consumerSecretKey: You must replace 'PRIVATE_API_KEY' with your valid private API key
    enum Key: String {
        case consumerKey = "b01bf2906c64ed00736de70ad1238d5f"
        case consumerSecretKey = "d99635136dadab3c"
    }
    
    // MARK: - Request OAuth1.0 Path
    
    enum OAuthPath: String {
        case requestTokenOAuth = "/services/oauth/request_token"
        case accessTokenOAuth = "/services/oauth/access_token"
        case authorizeOAuth = "/services/oauth/authorize"
    }
    
    // MARK: - Callback URL Scheme
    
    enum Callback: String {
        case schemeURL = "oauth-flickr://"
    }
    
}
