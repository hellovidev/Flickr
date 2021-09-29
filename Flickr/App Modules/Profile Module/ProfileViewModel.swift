//
//  ProfileViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

class ProfileViewModel {

    private let coordinator: CoordinatorService
    private let authorization: AuthorizationService
    private let profileNetworkManager: ProfileNetworkManager
    
    init(coordinator: CoordinatorService, authorization: AuthorizationService, token: AccessTokenAPI) {
        self.coordinator = coordinator
        self.authorization = authorization
        self.profileNetworkManager = .init(token)
    }
    
    func logout() {
        authorization.logout()
        coordinator.redirectToInitialViewController()
    }
    
    func requestProfile(completionHandler: @escaping (_ profile: Profile?, _ avatar: UIImage?) -> Void) {
        //var profile: Profile?
        //var avatar: UIImage?
        
        profileNetworkManager.requestProfile { result in
            switch result {
            case .success(let profileInformation):
                self.profileNetworkManager.requestAvatar(profile: profileInformation) { result in
                    switch result {
                    case .success(let avatarImage):
                        completionHandler(profileInformation, avatarImage)
                    case .failure(let error):
                        completionHandler(profileInformation, nil)
                        print("Download post information in \(#function) has error: \(error)")
                        return
                    }
                }
            case .failure(let error):
                completionHandler(nil, nil)
                print("Download post information in \(#function) has error: \(error)")
                return
            }
        }
    }
    
}
