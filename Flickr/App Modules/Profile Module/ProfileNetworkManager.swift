//
//  ProfileNetworkManager.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 28.09.2021.
//

import UIKit

class ProfileNetworkManager {
    
    private let networkService: NetworkService
    private let cacheAvatar: CacheStorageService<NSString, UIImage>
    private let cacheProfile: CacheStorageService<NSString, Profile>
    
    private let profileId: String
    
    init(_ token: AccessTokenAPI) {
        self.networkService = .init(token: token, publicKey: FlickrConstant.Key.consumerKey.rawValue, secretKey: FlickrConstant.Key.consumerSecretKey.rawValue)
        self.cacheAvatar = .init()
        self.cacheProfile = .init()
        self.profileId = token.nsid.removingPercentEncoding!
    }
    
    func refresh() {
        cacheAvatar.removeAll()
        cacheProfile.removeAll()
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
//        let cacheBuddyiconIdentifier = String(farm) + server + nsid as NSString
//        if let buddyiconCache = try? cacheBuddyicons.get(for: cacheBuddyiconIdentifier) {
//            completionHandler(.success(buddyiconCache))
//            group.leave()
//            return
//        }
//
//        networkService.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { [weak self] result in
//            completionHandler(result.map {
//                self?.cacheBuddyicons.set(for: $0, with: cacheBuddyiconIdentifier)
//                group.leave()
//                return $0
//            })
//        }
    }
    
}
