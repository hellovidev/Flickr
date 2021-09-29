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
    
    let postsNetworkManager: PostsNetworkManager
    let router: Observable<HomeRoute>
    
    let filters: [String] = ["50", "100", "200", "400"]
    
    init(networkService: NetworkService) {
        self.postsNetworkManager = .init(networkService: networkService)
        self.router = .init()
    }
    
    func requestPost(indexPath: IndexPath, completionHandler: @escaping (_ details: PostDetails?, _ buddyicon: UIImage?, _ image: UIImage?) -> Void) {
        let group = DispatchGroup()
        
        var details: PostDetails?
        var buddyicon: UIImage?
        var image: UIImage?
        
        postsNetworkManager.requestPostInformation(position: indexPath.row, group: group) { result in
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
            
            self?.postsNetworkManager.requestBuddyicon(post: details, group: group) { result in
                switch result {
                case .success(let avatar):
                    buddyicon = avatar
                case .failure(let error):
                    print("Download buddyicon error: \(error)")
                }
            }
            
            self?.postsNetworkManager.requestImage(post: details, group: group) { result in
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
    
}
































// MARK: - Methods
//private var networkService: NetworkService?

/*
 
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 if segue.identifier == "HomePath" {
 print("Go to home screen.")
 }
 }
 
 // Initialization 'NetworkService'
 self?.networkService = .init(accessTokenAPI: AccessTokenAPI(token: accessToken.token, secret: accessToken.secretToken, nsid: accessToken.userNSID.removingPercentEncoding!), publicConsumerKey: FlickrConstant.Key.consumerKey.rawValue, secretConsumerKey: FlickrConstant.Key.consumerSecretKey.rawValue)
 
 if let data = UserDefaults.standard.data(forKey: "token") {
 do {
 // Create JSON Decoder
 let decoder = JSONDecoder()
 
 // Decode Note
 let note = try decoder.decode(Note.self, from: data)
 
 } catch {
 print("Unable to Decode Note (\(error))")
 }
 }
 */

//self?.networkService?.getProfile(for: accessToken.userNSID.removingPercentEncoding!) { result in
//    switch result {
//    case .success(let profile):
//        print(profile)
//    case .failure(let error):
//        print(error)
//    }
//}

//                self?.networkService?.getPhotoComments(for: "109722179") {result in
//                    switch result {
//                    case .success(let comments):
//                        print(comments)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//
//self?.networkService?.getFavorites { result in
//    switch result {
//    case .success(let favorites):
//        print(favorites)
//    case .failure(let error):
//        print(error)
//    }
//}
//
//                self?.networkService?.getHotTags { result in
//                    switch result {
//                    case .success(let tags):
//                        print(tags)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }

//                self?.networkService?.getRecentPosts {result in
//                    switch result {
//                    case .success(let photos):
//                        print(photos)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//
//                self?.networkService?.getPhotoById(with: "51413316285") { result in
//                    switch result {
//                    case .success(let photoInfo):
//                        print(photoInfo)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//
//                self?.networkService?.addToFavorites(with: "49804197266") { result in
//                    switch result {
//                    case .success(let response):
//                        print("Photo with id \(49804197266) is added to favorites with status \(response)")
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//
//                self?.networkService?.removeFromFavorites(with: "49804197266") { result in
//                    switch result {
//                    case .success(let response):
//                        print("Photo with id \(49804197266) is removed from favorites with status \(response)")
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//


//                self?.networkService?.uploadNewPhoto(title: "New poster", description: "Added photo from iOS application.") {result in
//                    switch result {
//                    case .success(_): break
//                    case .failure(let error):
//                        print(error)
//                    }
//                }

//                self?.networkService?.getUserPhotos(for: "me") {result in
//                    switch result {
//                    case .success(let userPhotos):
//
//                        print("Response: \(userPhotos)")
//                    case .failure(let error):
//                        print(error)
//                    }
//                }

//self?.networkService?.deletePhotoById(with: "51413316285") {result in
//    switch result {
//    case .success(let resp):
//        print("Response: \(resp)")
//    case .failure(let error):
//        print(error)
//    }
//}
