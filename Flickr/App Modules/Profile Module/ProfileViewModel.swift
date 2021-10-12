//
//  ProfileViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

class ProfileViewModel {
    
    private weak var coordinator: GeneralCoordinator?
    
    private let profileNetworkManager: ProfileNetworkManager
    
    init(coordinator: GeneralCoordinator, nsid: String, network: NetworkService) {
        self.coordinator = coordinator
        self.profileNetworkManager = .init(nsid: nsid, network: network)
    }
    
    func didLogout() {
        coordinator?.didLogout()
    }
    
    func requestProfile(completionHandler: @escaping (_ profile: ProfileEntity?, _ avatar: UIImage?) -> Void) {
        profileNetworkManager.requestProfile { [weak self] result in
            switch result {
            case .success(let profileInformation):
                self?.profileNetworkManager.requestAvatar(profile: profileInformation) { result in
                    switch result {
                    case .success(let avatarImage):
                        completionHandler(profileInformation, avatarImage)
                    case .failure(let error):
                        completionHandler(profileInformation, nil)
                        print("Download avatar in \(#function) has error: \(error)")
                        return
                    }
                }
            case .failure(let error):
                completionHandler(nil, nil)
                print("Download profile information in \(#function) has error: \(error)")
                return
            }
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
