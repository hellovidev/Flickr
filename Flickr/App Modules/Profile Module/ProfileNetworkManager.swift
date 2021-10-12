//
//  ProfileNetworkManager.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 28.09.2021.
//

import UIKit

class ProfileNetworkManager {
    
    private var network: NetworkService
    
    private let nsid: String
    
    init(nsid: String, network: NetworkService) {
        self.network = network
        self.nsid = nsid
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
