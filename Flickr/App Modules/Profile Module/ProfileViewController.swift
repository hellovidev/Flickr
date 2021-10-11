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
    
    private lazy var skeletonAnimation: SkeletonAnimation = .init()
    
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
        viewModel.didLogout()
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
        let navigationLogotype: NavigationLogotype = .init()
        navigationItem.titleView = navigationLogotype
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
