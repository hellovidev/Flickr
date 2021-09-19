//
//  PostTableViewCell.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

// MARK: - PostTableViewCell

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var accountView: AccountView!
    @IBOutlet weak var postDescriptionView: PostDescriptionView!
    @IBOutlet weak var postImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accountView.nicknameLabel.text = nil
        accountView.locationLabel.text = nil
        
        startSkeletonAnimation(view: accountView.ownerAvatar)
        startSkeletonAnimation(view: postImage)
        startSkeletonAnimation(view: postDescriptionView)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func changeDateFormat(_ dateAsString: String, to format: String) -> String {
        guard let dateAsIntSince1970 = Int(dateAsString) else { fatalError() }
        let date: Date = Date(timeIntervalSince1970: TimeInterval(dateAsIntSince1970))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let formattedDateAsString = dateFormatter.string(from: date)
        return formattedDateAsString
    }
    
    private func buildNickname(fullName: String?, username: String?) -> String {
        var nickname = ""
        if let fullName = fullName {
            nickname += fullName
        }
        if let username = username {
            nickname += " (\(username))"
        }
        return nickname
    }
    
    func configure(for post: PostDetails) {
        // Setup header of cell
        let nickname = buildNickname(fullName: post.owner?.realName, username: post.owner?.username)
        accountView.nicknameLabel.text = nickname
        
        accountView.nicknameLabel.backgroundColor = .clear
        accountView.locationLabel.text = post.owner?.location.flatMap { $0 }
        accountView.locationLabel.backgroundColor = .clear
        
        // Setup footer of cell
        postDescriptionView.nicknameLabel.text = post.owner?.username.flatMap { $0 }
        postDescriptionView.nicknameLabel.backgroundColor = .clear
        
        postDescriptionView.postTitleLabel.text = post.title?.content.flatMap { $0 }
        postDescriptionView.postTitleLabel.backgroundColor = .clear
        postDescriptionView.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        
        postDescriptionView.publishedDateLabel.text = post.dateUploaded.flatMap { changeDateFormat($0, to: "dd MMM yyyy") }
        postDescriptionView.publishedDateLabel.backgroundColor = .clear
        
        stopSkeletonAnimation()
        postDescriptionView.layoutIfNeeded()
    }
    
    func setupBuddyicon(image: UIImage) {
        accountView.ownerAvatar.image = image
        accountView.ownerAvatar.backgroundColor = .clear
    }
    
    func setupPostImage(image: UIImage) {
        postImage.image = image
        postImage.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        startSkeletonAnimation(view: accountView.ownerAvatar)
        startSkeletonAnimation(view: postImage)
        startSkeletonAnimation(view: postDescriptionView)
        
        accountView.ownerAvatar.image = nil
        accountView.ownerAvatar.backgroundColor = .systemGray5
        
        accountView.nicknameLabel.text = nil
        accountView.nicknameLabel.backgroundColor = .systemGray5
        
        accountView.locationLabel.text = nil
        accountView.locationLabel.backgroundColor = .systemGray5
        
        postImage.image = nil
        postImage.backgroundColor = .systemGray5
        
        postDescriptionView.nicknameLabel.text = nil
        postDescriptionView.nicknameLabel.backgroundColor = .systemGray5
        
        postDescriptionView.postTitleLabel.text = nil
        postDescriptionView.postTitleLabel.backgroundColor = .systemGray5
        
        postDescriptionView.publishedDateLabel.text = nil
        postDescriptionView.publishedDateLabel.backgroundColor = .systemGray5
    }
    
    // MARK: - Animation
    
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
        gradientLayer.frame = bounds
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
    
}
