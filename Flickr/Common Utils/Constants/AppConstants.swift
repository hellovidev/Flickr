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
        case getFavorites = "flickr.favorites.getList"
        case getPopularPosts = "flickr.photos.getPopular"
        case getProfile = "flickr.profile.getProfile"
        case postPhoto = "flickr.blogs.postPhoto"
        case getComments = "flickr.photos.comments.getList"
        case getHotTags = "flickr.places.tagsForPlace"
    }
    
}
