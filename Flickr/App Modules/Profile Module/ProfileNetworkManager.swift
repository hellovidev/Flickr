//
//  ProfileNetworkManager.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 28.09.2021.
//

import UIKit

class ProfileNetworkManager {
    
    private let networkService: NetworkService
    
    private let profileId: String
    
    init(nsid: String, networkService: NetworkService) {
        self.networkService = networkService
        self.profileId = nsid
    }
    
    func requestProfile(completionHandler: @escaping (Result<Profile, Error>) -> Void) {
        networkService.getProfile(for: profileId) { result in
            completionHandler(result.map { $0 })
        }
    }
    
    func requestAvatar(profile: Profile, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard
            let farm = profile.iconFarm,
            let server = profile.iconServer,
            let nsid = profile.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }

        networkService.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { result in
            completionHandler(result.map { $0 })
        }
    }
    
}
