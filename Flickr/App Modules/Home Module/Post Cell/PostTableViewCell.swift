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
        
        startSkeletonAnimation(view: accountView.ownerAvatar)
        startSkeletonAnimation(view: postImage)
        startSkeletonAnimation(view: postDescriptionView)
        
        accountView.ownerAvatar.image = nil
        accountView.nicknameLabel.text = nil
        accountView.locationLabel.text = nil
        
        postImage.image = nil
        
        postDescriptionView.postTitleLabel.text = nil
        postDescriptionView.publishedDateLabel.text = nil
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
    
    private func buildDescription(nickname: String?, title: String?) -> NSMutableAttributedString {
        let postDescriptionNicknameLabelAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        
        let postDescriptionLabelAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]
        
        let description = NSMutableAttributedString(string: nickname ?? "", attributes: postDescriptionNicknameLabelAttributes)
        let title = NSAttributedString(string: " " + (title ?? ""), attributes: postDescriptionLabelAttributes)
        description.append(title)
        return description
    }
    
    func config(details: PostDetails?, buddyicon: UIImage?, image: UIImage?) {
        accountView.ownerAvatar.image = buddyicon
        postImage.image = image
        
        let nickname = buildNickname(fullName: details?.owner?.realName, username: details?.owner?.username)
        accountView.nicknameLabel.text = nickname
        
        let ownerLocation = details?.owner?.location.flatMap { $0 }
        accountView.locationLabel.text = ownerLocation
        
        let description = buildDescription(nickname: details?.owner?.username, title: details?.title?.content)
        postDescriptionView.postTitleLabel.attributedText = description

        let publishedDate = details?.dateUploaded.flatMap { changeDateFormat($0, to: "dd MMM yyyy") }
        postDescriptionView.publishedDateLabel.text = publishedDate
        
    
        postDescriptionView.frame.size.height = postDescriptionView.postTitleLabel.frame.height + postDescriptionView.publishedDateLabel.frame.height
        postDescriptionView.layoutIfNeeded()
        self.layoutIfNeeded()
        
        stopSkeletonAnimation()
    }
    
    func configure(for post: PostDetails) {
        let nickname = buildNickname(fullName: post.owner?.realName, username: post.owner?.username)
        accountView.nicknameLabel.text = nickname
        
        let ownerLocation = post.owner?.location.flatMap { $0 }
        accountView.locationLabel.text = ownerLocation
        
        let description = buildDescription(nickname: post.owner?.username, title: post.title?.content)
        postDescriptionView.postTitleLabel.attributedText = description

        let publishedDate = post.dateUploaded.flatMap { changeDateFormat($0, to: "dd MMM yyyy") }
        postDescriptionView.publishedDateLabel.text = publishedDate
        
    
        postDescriptionView.frame.size.height = postDescriptionView.postTitleLabel.frame.height + postDescriptionView.publishedDateLabel.frame.height
        postDescriptionView.layoutIfNeeded()
        self.layoutIfNeeded()
        
        stopSkeletonAnimation()
    }
    
    func setupBuddyicon(image: UIImage) {
        accountView.ownerAvatar.image = image
    }
    
    func setupPostImage(image: UIImage) {
        postImage.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        startSkeletonAnimation(view: accountView.ownerAvatar)
        startSkeletonAnimation(view: postImage)
        startSkeletonAnimation(view: postDescriptionView)
        
        accountView.ownerAvatar.image = nil
        accountView.nicknameLabel.text = nil
        accountView.locationLabel.text = nil
        
        postImage.image = nil
        
        postDescriptionView.postTitleLabel.text = nil
        postDescriptionView.publishedDateLabel.text = nil
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
