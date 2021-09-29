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
    
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSkeletonAnimation(view: avatarImage)

        setupAvatar()
        setupLogoutButton()
        setupNavigationTitle()
        
        realNameLabel.text = nil
        descriptionLabel.text = nil
        
        viewModel.requestProfile { [weak self] profile, avatar in
            self?.avatarImage.image = avatar
            self?.realNameLabel.text = profile?.realName?.content
            self?.descriptionLabel.text = profile?.description?.content
            
            self?.stopSkeletonAnimation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        viewModel.logout()
    }
    
    private func setupAvatar() {
        avatarContainer.layer.cornerRadius = avatarContainer.frame.height / 2
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        avatarContainer.layer.borderColor = UIColor.systemGray3.cgColor
        avatarContainer.layer.borderWidth = 1.5
        
//        avatarContainer.layer.shadowColor = UIColor.gray.cgColor
//        avatarContainer.layer.shadowOpacity = 0.5
//        avatarContainer.layer.shadowOffset = .zero
//        avatarContainer.layer.shadowRadius = 10
//        avatarContainer.layer.shouldRasterize = true
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
    
    private var gradientLayerArray: [CAGradientLayer] = .init()
    
    private func startSkeletonAnimation(view: UIView) {
        let gradientLayer: CAGradientLayer = .init()
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: -1.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 2.5, y: 0.75)
        gradientLayer.drawsAsynchronously = true
        
        let colors = [
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor,
            UIColor.systemGray6.cgColor,
        ]
        gradientLayer.colors = colors.reversed()
        
        let locations: [NSNumber] = [0.0, 0.25, 1.0]
        gradientLayer.locations = locations
        view.layer.addSublayer(gradientLayer)
        
        let gradientAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        gradientAnimation.fromValue = [0.0, 0.0, 0.25]
        gradientAnimation.toValue = [0.75 ,1.0, 1.0]
        gradientAnimation.duration = 0.75
        gradientAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        gradientAnimation.repeatCount = .infinity
        gradientAnimation.autoreverses = true
        gradientAnimation.isRemovedOnCompletion = false
        
        gradientLayer.add(gradientAnimation, forKey: "gradientAnimation")
        gradientLayerArray.append(gradientLayer)
    }
    
    private func stopSkeletonAnimation() {
        gradientLayerArray.forEach { $0.removeFromSuperlayer() }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
