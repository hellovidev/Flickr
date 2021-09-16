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
    @IBOutlet weak var metaView: PostDescriptionView!
    @IBOutlet weak var postImage: UIImageView!
    
    private var representedIdentifier: String?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        startSkeletonAnimation(view: accountView.ownerAvatar)
        startSkeletonAnimation(view: postImage)
        startSkeletonAnimation(view: metaView.view)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func convertDateToSpecificFormat(_ dateAsString: String) -> String {
        guard let dateAsIntSince1970 = Int(dateAsString) else { fatalError() }
        let date: Date = Date(timeIntervalSince1970: TimeInterval(dateAsIntSince1970))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        let formattedDateAsString = dateFormatter.string(from: date)
        return formattedDateAsString
    }
    
    func configure(for post: PostDetails) {
        representedIdentifier = post.id

        // Setup header of cell
        accountView.nicknameLabel.text = "\(post.owner?.realName.flatMap { $0 } ?? "") (\(post.owner?.username.flatMap { $0 } ?? ""))"
        accountView.nicknameLabel.backgroundColor = .clear
        accountView.locationLabel.text = post.owner?.location.flatMap { $0 }
        accountView.locationLabel.backgroundColor = .clear
                
        // Setup footer of cell
        metaView.nicknameLabel.text = post.owner?.username.flatMap { $0 }
        metaView.nicknameLabel.backgroundColor = .clear

        metaView.postTitleLabel.text = post.title?.content.flatMap { $0 }
        metaView.postTitleLabel.backgroundColor = .clear
        metaView.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        
        metaView.publishedDateLabel.text = post.dateUploaded.flatMap(convertDateToSpecificFormat)
        metaView.publishedDateLabel.backgroundColor = .clear
        
        stopSkeletonAnimation()
    }
    
    func setupBuddyIcon(image: UIImage?, postId: String) {
        // Setup account avatar image
        if (representedIdentifier == postId) {
            accountView.ownerAvatar.image = image
            accountView.ownerAvatar.backgroundColor = .clear
        }
    }
    
    func setupPostImage(image: UIImage?, postId: String) {
        // Setup cell image
        if (representedIdentifier == postId) {
            postImage.image = image
            postImage.backgroundColor = .clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        startSkeletonAnimation(view: accountView.ownerAvatar)
        startSkeletonAnimation(view: postImage)
        startSkeletonAnimation(view: metaView.view)
        
        accountView.ownerAvatar.image = nil
        accountView.ownerAvatar.backgroundColor = .systemGray5

        accountView.nicknameLabel.text = nil
        accountView.nicknameLabel.backgroundColor = .systemGray5

        accountView.locationLabel.text = nil
        accountView.locationLabel.backgroundColor = .systemGray5
        
        postImage.image = nil
        postImage.backgroundColor = .systemGray5

        metaView.nicknameLabel.text = nil
        metaView.nicknameLabel.backgroundColor = .systemGray5

        metaView.postTitleLabel.text = nil
        metaView.postTitleLabel.backgroundColor = .systemGray5
        
        metaView.publishedDateLabel.text = nil
        metaView.publishedDateLabel.backgroundColor = .systemGray5
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
