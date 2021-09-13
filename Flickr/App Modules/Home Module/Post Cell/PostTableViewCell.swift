//
//  PostTableViewCell.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.09.2021.
//

import UIKit
import Combine

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var accountView: AccountView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(for post: PostDetails?) {

        accountView.nicknameLabel.text = "\(String(describing: post?.owner?.realName)) (\(String(describing: post?.owner?.username)))"
        accountView.locationLabel.text = post?.owner?.location ?? "Unknown"
        //postImage.image = UIImage(named: "TestImage")
        

        //fetchImage(endpoint: post?.urls?.url?.first?._content ?? "")

        
        postTitle.text = post?.title?.content
        nicknameLabel.text = post?.owner?.username
        dateLabel.text = post?.dates?.taken//"21 Jun 2001"
        
        accountView.ownerAvatar.layer.cornerRadius = accountView.ownerAvatar.frame.height / 2
        accountView.ownerAvatar.layer.borderWidth = 1
        accountView.ownerAvatar.layer.borderColor = CGColor.init(gray: 1, alpha: 1)
        //accountView.nicknameLabel.text = post.owner
        
        guard
            let photoId = post?.id,
            let photoSecret = post?.secret,
            let serverId = post?.server
        else {
            return
        }
        
        let size = "b"
        let format = "jpg"
        
        guard let url = URL(string: "https://live.staticflickr.com/\(serverId)/\(photoId)_\(photoSecret)_\(size).\(format)") else { return }
        postImage.load(url: url) { result in
            switch result {
            case .success(let image):
                
                let ratio = image.size.width / image.size.height
                if self.frame.width > self.frame.height {
                    let newHeight = self.frame.width / ratio
                   self.postImage.frame.size = CGSize(width: self.frame.width, height: newHeight)
                }
                else{
                    let newWidth = self.frame.height * ratio
                   self.postImage.frame.size = CGSize(width: newWidth, height: self.frame.height)
                }
                self.postImage.image = image

                self.layoutIfNeeded()
            case .failure(let error):
                print(error)
            }
        }
        
        guard
        let iconFarm = post?.owner?.iconFarm,
            let iconServer = post?.owner?.iconServer,
            let nsid = post?.owner?.nsid
        else {
            return
        }
        guard let urlAvatar = URL(string: "http://farm\(iconFarm).staticflickr.com/\(iconServer)/buddyicons/\(nsid).jpg") else { return }
        accountView.ownerAvatar.load(url: urlAvatar) { result in
            switch result {
            
            case .success(let image):
                self.accountView.ownerAvatar.image = image
            case .failure(let error):
                print(error)
            }
            
        }
        


    }
    
    

    
    
}

extension UIImageView {
    
    func load(url: URL, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completionHandler(.success(image))
                        //self?.image = image
                    }
                }
            }
        }
    }
    
}
