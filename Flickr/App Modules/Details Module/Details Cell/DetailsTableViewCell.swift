//
//  DetailsTableViewCell.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 10.10.2021.
//

import UIKit

protocol DetailsCellDelegate: AnyObject {
    func didClickFavourite(_ cell: DetailsTableViewCell)
}

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var detailsImage: UIImageView!
    @IBOutlet weak var detailsTitle: UILabel!
    @IBOutlet weak var detailsDescription: UILabel!
    @IBOutlet weak var detailsDate: UILabel!
    @IBOutlet weak var detailsFavourite: UIButton!
    
    weak var delegate: DetailsCellDelegate?
    
    private let skeletonAnimation: SkeletonAnimation = .init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        skeletonAnimation.startAnimationFor(view: detailsImage)
        skeletonAnimation.startAnimationFor(view: detailsTitle, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: detailsDescription, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: detailsDate, cornerRadius: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.selectionStyle = .none
    }
    
    func configure(details: Post) {
        detailsImage.image = details.image
        
        // Setup Post Description
        if let title = details.title, !title.isEmpty {
            detailsTitle.text = title
        } else {
            detailsTitle.text = "No title"
        }
        
        if let description = details.description, !description.isEmpty {
            detailsDescription.text = description
        } else {
            detailsDescription.text = "No description"
        }
        detailsDate.text = details.publishedAt?.prepareStringAsDate()

        let favouriteStateImage = (details.isFavourite == nil || details.isFavourite == false) ? FavouriteState.isNotFavourite.image : FavouriteState.isFavourite.image
        detailsFavourite.setImage(favouriteStateImage, for: .normal)
        
        skeletonAnimation.stopAllAnimations()
    }
    
    @IBAction func favouriteAction(_ sender: UIButton) {
        delegate?.didClickFavourite(self)
    }
    
}
