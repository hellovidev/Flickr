//
//  HomeViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.09.2021.
//

import UIKit

enum HomeRoute {
    case openPost(id: String)
}

class HomeViewModel {
    
    let homeNetworkManager: HomeNetworkManager
    
    let router: Observable<HomeRoute>
    
    let filters: [String] = ["50", "100", "200", "400"]
    
    private weak var coordinator: GeneralCoordinator?

    init(coordinator: GeneralCoordinator, networkService: NetworkService) {
        self.coordinator = coordinator
        self.homeNetworkManager = .init(networkService: networkService)
        self.router = .init()
    }
    
    func requestPost(indexPath: IndexPath, completionHandler: @escaping (_ details: PostDetails?, _ buddyicon: UIImage?, _ image: UIImage?) -> Void) {
        let group = DispatchGroup()
        
        var details: PostDetails?
        var buddyicon: UIImage?
        var image: UIImage?
        
        homeNetworkManager.requestPostInformation(position: indexPath.row, group: group) { result in
            switch result {
            case .success(let information):
                details = information
            case .failure(let error):
                completionHandler(nil, nil, nil)
                print("Download post information in \(#function) has error: \(error)")
                return
            }
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            
            guard let details = details else {
                completionHandler(nil, nil, nil)
                print("Line \(#line) has empty post details")
                return
            }
            
            self?.homeNetworkManager.requestBuddyicon(post: details, group: group) { result in
                switch result {
                case .success(let avatar):
                    buddyicon = avatar
                case .failure(let error):
                    print("Download buddyicon error: \(error)")
                }
            }
            
            self?.homeNetworkManager.requestImage(post: details, group: group) { result in
                switch result {
                case .success(let cover):
                    image = cover
                case .failure(let error):
                    print("Download image error: \(error)")
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                //print("Post constructed: (\(details), \(String(describing: buddyicon)), \(String(describing: image))")
                DispatchQueue.main.async {
                    completionHandler(details, buddyicon, image)
                }
            }
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
