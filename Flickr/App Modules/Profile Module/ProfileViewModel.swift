//
//  ProfileViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

// MARK: - ProfileViewModel

class ProfileViewModel {
    
    private weak var coordinator: GeneralCoordinator?
    
    private let repository: ProfileRepository
    
    init(coordinator: GeneralCoordinator, network: NetworkService) {
        self.coordinator = coordinator
        self.repository = .init(network: network)
    }
    
    func didLogout() {
        coordinator?.didLogout()
    }
    
    func requestProfile(completionHandler: @escaping (_ profile: ProfileEntity?, _ avatar: UIImage?) -> Void) {
        repository.requestProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.repository.requestAvatar(profile: profile) { result in
                    switch result {
                    case .success(let avatarImage):
                        completionHandler(profile, avatarImage)
                    case .failure(let error):
                        completionHandler(profile, nil)
                        print("Download avatar in \(#function) has error: \(error)")
                    }
                }
            case .failure(let error):
                completionHandler(nil, nil)
                print("Download profile information in \(#function) has error: \(error)")
            }
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
