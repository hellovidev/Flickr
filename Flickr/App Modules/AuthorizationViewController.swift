//
//  AuthorizationViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 18.08.2021.
//

import UIKit

// MARK: - UIViewController

class AuthorizationViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let loginButtonTextAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        
        let loginButtonText = NSMutableAttributedString(string: "Log in with ", attributes: nil)
        let flickrLinkText = NSAttributedString(string: "flickr.com", attributes: loginButtonTextAttributes)
        loginButtonText.append(flickrLinkText)
        loginButton.setAttributedTitle(loginButtonText, for: .normal)
        loginButton.layer.cornerRadius = 5
        
        let signupLabelTextAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]

        signupLabel.sizeToFit()
        signupLabel.attributedText = NSAttributedString(string: "Sign up.", attributes: signupLabelTextAttributes)
        
        questionLabel.sizeToFit()
    }
    

    /*
     let text = NSMutableAttributedString(string: "Already have an account? ")
     text.addAttribute(NSAttributedStringKey.font,
                       value: UIFont.systemFont(ofSize: 12),
                       range: NSRange(location: 0, length: text.length))
     
     let interactableText = NSMutableAttributedString(string: "Sign in!")
     interactableText.addAttribute(NSAttributedStringKey.font,
                                   value: UIFont.systemFont(ofSize: 12),
                                   range: NSRange(location: 0, length: interactableText.length))
     
     // Adding the link interaction to the interactable text
     interactableText.addAttribute(NSAttributedStringKey.link,
                                   value: "SignInPseudoLink",
                                   range: NSRange(location: 0, length: interactableText.length))
     
     // Adding it all together
     text.append(interactableText)
     
     // Set the text view to contain the attributed text
     textView.attributedText = text
     
     // Disable editing, but enable selectable so that the link can be selected
     textView.isEditable = false
     textView.isSelectable = true
     textView.delegate = self
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signupAction = UITapGestureRecognizer(target: self, action: #selector(signupAction(sender:)))
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(signupAction)
    }

    @IBAction func loginAction(_ sender: UIButton) {
        AuthorizationService.login(presenter: self) { [weak self] result in
            switch result {
            case .success(let message):
                print(message)
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "HomePath", sender: self)
                }
            case .failure(let error):
                self?.showAlert(title: "Authorize error", message: error.localizedDescription, button: "OK")
            }
        }
    }
    
    @IBAction func signupAction(sender: UITapGestureRecognizer) {
        print("SIGNUP")
        AuthorizationService.signup()
    }
        
    deinit {
        print("\(type(of: self)) deinited.")
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
