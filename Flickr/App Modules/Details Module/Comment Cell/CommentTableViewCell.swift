//
//  CommentTableViewCell.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.10.2021.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentOwnerAvatar: UIImageView!
    @IBOutlet weak var commentContent: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    
    private lazy var skeletonAnimation: SkeletonAnimation = .init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        skeletonAnimation.startAnimationFor(view: commentOwnerAvatar)
        skeletonAnimation.startAnimationFor(view: commentContent, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: commentDate, cornerRadius: true)
        
        commentOwnerAvatar.layer.cornerRadius = commentOwnerAvatar.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(_ comment: CommentProtocol) {
        commentOwnerAvatar.image = comment.ownerAvatar
        commentContent.attributedText = NSMutableAttributedString.prepareContent(username: comment.username, content: comment.commentContent)
        
        let dateAsString = comment.publishedAt?.prepareStringAsDate()
        commentDate.text = PrepareTextFormatter.prepareTextField(dateAsString, placeholder: .date)
        
        skeletonAnimation.stopAllAnimations()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        commentOwnerAvatar.image = nil
        commentContent.text = "No content"
        commentDate.text = "No date"
        
        skeletonAnimation.startAnimationFor(view: commentOwnerAvatar)
        skeletonAnimation.startAnimationFor(view: commentContent, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: commentDate, cornerRadius: true)
    }
    
}
