//
//  Flickr.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import Foundation

// MARK: - Flickr Constants

enum Flickr: String {
    
    case baseURL = "https://www.flickr.com"
    case uploadURL = "https://up.flickr.com/services/upload/"
    case requestURL = "https://www.flickr.com/services/rest"
    
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

    enum Key: String {
        case consumerKey = "jnsdvlkjsdncn4fel2kjnlkj23d"
        case consumerSecretKey = "sdfmlksdmf342mfkwed"
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
