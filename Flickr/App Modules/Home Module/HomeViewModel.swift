//
//  HomeViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.09.2021.
//

import UIKit

struct Filter {
    let title: String
    let color: UIColor
}

enum HomeRoute {
    //case `self`
    case fullPost(id: String)
}

struct Post {
    var details: PostDetails?
    var image: UIImage?
    var buddyicon: UIImage?
//    let owner: String
//    let ownerLocation: String
//    let description: String
//    let publishedAt: String
    
}

class HomeViewModel {
    
    var postsNetworkManager: PostsNetworkManager!
    var router: Observable<HomeRoute> = .init()//.init(.`self`)
    
    let filters: [Filter] = [
        Filter(title: "50", color: .systemBlue),
        Filter(title: "100", color: .systemPink),
        Filter(title: "200", color: .systemRed),
        Filter(title: "400", color: .systemTeal)
    ]
    

    
    func requestPost(indexPath: IndexPath, completionHandler: @escaping (_ details: PostDetails?, _ buddyicon: UIImage?, _ image: UIImage?) -> Void) {
        let group = DispatchGroup()
        var details: PostDetails?
        var buddyicon: UIImage?
        var image: UIImage?
        
        postsNetworkManager.requestPostInformation(position: indexPath.row, group: group) { [weak self] result in
            switch result {
            case .success(let postInformation):
                details = postInformation.information
//                if postInformation.type == .network {
//                    if let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
//                        cellForRow.configure(for: postInformation.information)
//                    }
//                } else {
//                    postCell.configure(for: postInformation.information)
//                }

            case .failure(let error):
                print("\(#function) has error: \(error.localizedDescription)")
            }
        }
        


        group.notify(queue: DispatchQueue.global()) {
          print("Completed work: \(details)")
            
            guard let postDetails = details else {
                completionHandler(nil, nil, nil)
                return
            }
            
            
            self.postsNetworkManager.requestBuddyicon(post: postDetails, group: group) { result in
                switch result {
                case .success(let postBuddyicon):
                    buddyicon = postBuddyicon.image
    //                if postBuddyicon.type == .network {
    //                    if let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
    //                        cellForRow.setupBuddyicon(image: postBuddyicon.image)
    //                    }
    //                } else {
    //                    postCell.setupBuddyicon(image: postBuddyicon.image)
    //                }

                case .failure(let error):
                    print("Download buddyicon error: \(error)")
                }
            }
            
            self.postsNetworkManager.requestImage(post: postDetails, group: group) { result in
                switch result {
                case .success(let postImage):
                    image = postImage.image
    //                if postImage.type == .network {
    //                    guard let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell else { return }
    //                    cellForRow.setupPostImage(image: postImage.image)
    //                } else {
    //                    postCell.setupPostImage(image: postImage.image)
    //                }
                case .failure(let error):
                    print("Download image error: \(error)")
                }
            }
            
            group.notify(queue: DispatchQueue.global()) {
              //print("Completed work: \(post)")
                DispatchQueue.main.async {
                    
                
                completionHandler(details, buddyicon, image)
                }
            }
            
          // Kick off the movies API calls
          //PlaygroundPage.current.finishExecution()
        }
    }
    
    
    
    
    
    
    
    
    
    
//    func requestAndSetupPostIntoTable(tableView: UITableView, postCell: PostTableViewCell, indexPath: IndexPath) {
//
//    }

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
