//
//  PhotoDetailsTableViewCell.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit

// MARK: - PhotoDetailsTableViewCell

class PhotoDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var accountView: AccountView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postPublishedDate: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    
    private let skeletonAnimation: SkeletonAnimation = .init()
    
    var photoDetailsId: String?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setupDefaultView()
        setupAnimation()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configuration(details: PhotoDetailsEntity?, buddyicon: UIImage?, image: UIImage?) {
        photoDetailsId = details?.id
        
        accountView.ownerAvatar.image = buddyicon
        
        let ownerAccountName = PrepareTextFormatter.prepareUserAccountName(name: details?.owner?.realName, username: details?.owner?.username)
        accountView.ownerAccountName.text = ownerAccountName
        
        let ownerLocation = PrepareTextFormatter.prepareTextField(details?.owner?.location, placeholder: .location)
        accountView.ownerLocation.text = ownerLocation
        
        postImage.image = image
                
        let description = NSMutableAttributedString.prepareContent(username: details?.owner?.username, content: details?.title?.content)
        postDescription.attributedText = description

        let dateAsString = details?.dateUploaded?.prepareStringAsDate()
        let date = PrepareTextFormatter.prepareTextField(dateAsString, placeholder: .date)
        postPublishedDate.text = date
        
        skeletonAnimation.stopAllAnimations()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setupDefaultView()
        setupAnimation()
    }
    
    private func setupDefaultView() {
        accountView.ownerAvatar.image = nil
        accountView.ownerAccountName.text = "No account name"
        accountView.ownerLocation.text = "No location"
        
        postImage.image = nil
        postDescription.text = "No name & No description"
        postPublishedDate.text = "No date"
    }
    
    private func setupAnimation() {
        skeletonAnimation.startAnimationFor(view: accountView.ownerAvatar)
        skeletonAnimation.startAnimationFor(view: accountView.ownerAccountName, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: accountView.ownerLocation, cornerRadius: true)
        
        skeletonAnimation.startAnimationFor(view: postImage)
        skeletonAnimation.startAnimationFor(view: postDescription, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: postPublishedDate, cornerRadius: true)
    }
    
}
