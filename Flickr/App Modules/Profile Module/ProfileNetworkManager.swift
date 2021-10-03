//
//  ProfileNetworkManager.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 28.09.2021.
//

import UIKit

class ProfileNetworkManager {
    
    private let networkService: NetworkService
    
    private let nsid: String
    
    init(nsid: String, networkService: NetworkService) {
        self.networkService = networkService
        self.nsid = nsid
    }
    
    func requestProfile(completionHandler: @escaping (Result<ProfileEntity, Error>) -> Void) {
        networkService.getProfile(for: nsid, completionHandler: completionHandler)
    }
    
    func requestAvatar(profile: ProfileEntity, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard
            let farm = profile.iconFarm,
            let server = profile.iconServer,
            let nsid = profile.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        networkService.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid, completionHandler: completionHandler)
    }
    
}
