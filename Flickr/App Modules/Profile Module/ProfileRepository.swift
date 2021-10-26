//
//  ProfileRepository.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 28.09.2021.
//

import UIKit

// MARK: - ProfileRepository

class ProfileRepository {
    
    private var network: Network
    
    @UserDefaultsBacked(key: UserDefaults.Keys.nsid.rawValue)
    private var nsid: String!
    
    init(network: Network) {
        self.network = network
    }
    
    func requestProfile(completionHandler: @escaping (Result<ProfileEntity, Error>) -> Void) {
        network.getProfile(for: nsid, completionHandler: completionHandler)
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
        
        network.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid, completionHandler: completionHandler)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
