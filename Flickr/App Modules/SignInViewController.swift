//
//  ViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit

// MARK: - UIViewController

class SignInViewController: UIViewController {
    private var networkService: NetworkService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User athorization request
        FlickrOAuthService.shared.flickrLogin(presenter: self) { [weak self] result in
            switch result {
            case .success(let accessToken):
                // Initialization 'NetworkService'
                self?.networkService = .init(withAccess: AccessTokenAPI(token: accessToken.token, secret: accessToken.secretToken, nsid: accessToken.userNSID.removingPercentEncoding!))
                
                // MARK: - Methods
                self?.networkService?.getProfile(for: accessToken.userNSID.removingPercentEncoding!) { result in
                    switch result {
                    case .success(let profile):
                        print(profile)
                    case .failure(let error):
                        print(error)
                    }
                }

//                self?.networkService?.getPhotoComments(for: "109722179") {result in
//                    switch result {
//                    case .success(let comments):
//                        print(comments)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//
//                self?.networkService?.getFavorites { result in
//                    switch result {
//                    case .success(let favorites):
//                        print(favorites)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//
//                self?.networkService?.getHotTags { result in
//                    switch result {
//                    case .success(let tags):
//                        print(tags)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }

//                self?.networkService?.getPopularPosts {result in
//                    switch result {
//                    case .success(let photos):
//                        print(photos)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//
//                self?.networkService?.getPhotoById(with: "51403173555") { result in
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

                
                self?.networkService?.uploadNewPhoto(title: "Poster", description: "New photo from iOS application.") {result in
                    switch result {
                    case .success(_): break
                    case .failure(let error):
                        print(error)
                    }
                }
                
//                self?.networkService?.getUserPhotos(for: "me") {result in
//                    switch result {
//                    case .success(let userPhotos):
//
//                        print("Response: \(userPhotos)")
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
                
//                self?.networkService?.deletePhotoById(with: "51404594320") {result in
//                    switch result {
//                    case .success(let resp):
//                        print("Response: \(resp)")
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
            case .failure(let error):
                switch error {
                case ErrorMessage.notFound:
                    print("Error OAuth: ")
                case ErrorMessage.error(let message):
                    print("Error OAuth: \(message)")
                default:
                    print("Error OAuth: \(error.localizedDescription)")
                }
            }
        }
    }
    
}
