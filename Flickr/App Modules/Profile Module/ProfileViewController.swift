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
        
        setupAnimation()
        setupAvatar()
        setupLogoutButton()
        setupNavigationTitle()
        
        requestProfile()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        viewModel.didLogout()
    }
    
    private func requestProfile() {
        viewModel.requestProfile { [weak self] profile, avatar in
            self?.avatarImage.image = avatar
            
            let realName = PrepareTextFormatter.prepareTextField(profile?.realName?.content, placeholder: .name)
            self?.realNameLabel.text = realName
            
            let description = PrepareTextFormatter.prepareTextField(profile?.description?.content, placeholder: .description)
            self?.descriptionLabel.text = description
            
            self?.skeletonAnimation.stopAllAnimations()
        }
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
    
    private func setupAnimation() {
        skeletonAnimation.startAnimationFor(view: avatarImage)
        skeletonAnimation.startAnimationFor(view: realNameLabel, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: descriptionLabel, cornerRadius: true)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
