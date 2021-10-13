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
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postPublishedDate: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    
    private let skeletonAnimation: SkeletonAnimation = .init()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accountView.ownerAvatar.image = nil
        accountView.ownerAccountName.text = "No account name"
        accountView.ownerLocation.text = "No location"
        
        postImage.image = nil
        
        postDescription.text = "No name & No description"
        postPublishedDate.text = "No date"
        
        skeletonAnimation.startAnimationFor(view: accountView.ownerAvatar)
        skeletonAnimation.startAnimationFor(view: postImage)
        
        skeletonAnimation.startAnimationFor(view: accountView.ownerAccountName, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: accountView.ownerLocation, cornerRadius: true)
        
        skeletonAnimation.startAnimationFor(view: postDescription, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: postPublishedDate, cornerRadius: true)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    var postId: String?
    
    func config(details: PostDetails?, buddyicon: UIImage?, image: UIImage?) {
        skeletonAnimation.stopAllAnimations()

        postId = details?.id
        
        accountView.ownerAvatar.image = buddyicon
        postImage.image = image
        
        let nickname = PrepareTextFormatter.prepareUserAccountName(name: details?.owner?.realName, username: details?.owner?.username)
        accountView.ownerAccountName.text = nickname
        
        let ownerLocation = PrepareTextFormatter.prepareTextField(details?.owner?.location, placeholder: .location)
        accountView.ownerLocation.text = ownerLocation
        
        let description = NSMutableAttributedString.prepareContent(username: details?.owner?.username, content: details?.title?.content)
        postDescription.attributedText = description

        let dateAsString = details?.dateUploaded?.prepareStringAsDate()
        let date = PrepareTextFormatter.prepareTextField(dateAsString, placeholder: .date)
        postPublishedDate.text = date
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        accountView.ownerAvatar.image = nil
        accountView.ownerAccountName.text = "No account name"
        accountView.ownerLocation.text = "No location"
        
        postImage.image = nil
        
        postDescription.text = "No name & No description"
        postPublishedDate.text = "No date"
        
        skeletonAnimation.startAnimationFor(view: accountView.ownerAvatar)
        skeletonAnimation.startAnimationFor(view: postImage)
        
        skeletonAnimation.startAnimationFor(view: postDescription, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: postPublishedDate, cornerRadius: true)

        skeletonAnimation.startAnimationFor(view: accountView.ownerAccountName, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: accountView.ownerLocation, cornerRadius: true)
    }
    
}
