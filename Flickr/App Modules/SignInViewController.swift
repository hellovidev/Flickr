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
        FlickrOAuth.shared.flickrLogin(presenter: self) { [weak self] result in
            switch result {
            case .success(let accessToken):
                // Initialization 'NetworkService'
                self?.networkService = .init(withAccess: AccessTokenAPI(token: accessToken.token, secret: accessToken.secretToken, nsid: accessToken.userNSID.removingPercentEncoding!))
//                self?.networkService?.getProfile { result in
//                    switch result {
//                    case .success(let profile):
//                        print(profile)
//                    case .failure(let error):
//                        print(error)
//                    }
//
//                }
//                self?.networkService?.getPhotoComments(for: "109722179") {result in
//                    switch result {
//                    case .success(let comments):
//                        print(comments)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
            
//                self?.networkService?.getFavorites { result in
//                                        switch result {
//                                        case .success(let favorites):
//                                            print(favorites)
//                                        case .failure(let error):
//                                            print(error)
//                                        }
//
//                }
                self?.networkService?.getHotTags(count: 10) {result in
                                                            switch result {
                                                            case .success(let tags):
                                                                print(tags)
                                                            case .failure(let error):
                                                                print(error)
                                                            }
                    
                }
//                self?.networkService?.postNewPhoto(photoId: UUID().uuidString, title: "First photo loaded from iPhone", description: "WOW!") { str in
//                    print(str)
//
//                }
            
//                self?.networkService?.getPopularPosts {result in
//                                                            switch result {
//                                                            case .success(let photos):
//                                                                print(photos)
//                                                            case .failure(let error):
//                                                                print(error)
//                                                            }
//                    
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
