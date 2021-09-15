//
//  GalleryViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - GalleryViewController

class GalleryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
