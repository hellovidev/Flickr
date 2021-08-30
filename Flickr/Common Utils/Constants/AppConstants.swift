//
//  AppConstants.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import Foundation

// MARK: - App Constants

enum Constant {
    
    // MARK: - Notification Names Identifiers
    
    enum NotificationName: String {
        case callbackAuthorization = "CallbackAuthorizationNotification"
        case triggerBrowserTargetComplete = "BrowserTargetCompleteNotification"
        case websiteСonfirmationRequired = "СonfirmationRequiredNotification"
    }
    
    // MARK: - Flickr Methods Identifiers (Documentstion: https://www.flickr.com/services/api/)
    
    enum FlickrMethod: String {
        // Profile screen
        case getProfile = "flickr.profile.getProfile"
        
        // Home screen
        case getHotTags = "flickr.tags.getHotList"
        case getRecentPosts = "flickr.photos.getRecent" // => "flickr.photos.getPopular"
        case getPhotoInfo = "flickr.photos.getInfo"
        case getPhotoComments = "flickr.photos.comments.getList"
        case addPhotoComment = "flickr.photos.comments.addComment"
        case deletePhotoComment = "flickr.photos.comments.deleteComment"
        case addToFavorites = "flickr.favorites.add"
        case removeFromFavorites = "flickr.favorites.remove"
        
        // Gallery screen
        case getUserPhotos = "flickr.people.getPhotos" // => "flickr.___.getUserPhotos"
        case deleteUserPhotoById = "flickr.photos.delete"
        
        // ???
        case getFavorites = "flickr.favorites.getList"
    }
    
}
