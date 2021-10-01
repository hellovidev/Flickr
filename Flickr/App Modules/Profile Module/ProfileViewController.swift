//
//  ProfileViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - ProfileViewController

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var realNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    private let skeletonAnimation: SkeletonAnimation = .init()
    
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skeletonAnimation.startAnimationFor(view: avatarImage)
        skeletonAnimation.startAnimationFor(view: realNameLabel, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: descriptionLabel, cornerRadius: true)
        
        setupAvatar()
        setupLogoutButton()
        setupNavigationTitle()
        
        viewModel.requestProfile { [weak self] profile, avatar in
            
            // Set values of request
            self?.avatarImage.image = avatar
            self?.realNameLabel.text = profile?.realName?.content ?? "No real name"
            self?.descriptionLabel.text = profile?.description?.content ?? "No description"
            
            // Stop skeleton animations
            self?.skeletonAnimation.stopAllAnimations()
        }
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        viewModel.logout()
    }
    
    private func setupAvatar() {
        avatarContainer.layer.cornerRadius = avatarContainer.frame.height / 2
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        avatarContainer.layer.borderColor = UIColor.systemGray3.cgColor
        avatarContainer.layer.borderWidth = 1.5
    }
    
    private func setupLogoutButton() {
        logoutButton.layer.cornerRadius = 6
    }
    
    private func setupNavigationTitle() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageName.logotype.rawValue)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        imageView.center = view.convert(view.center, from: imageView);
        view.addSubview(imageView)
        
        navigationItem.titleView = view
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
