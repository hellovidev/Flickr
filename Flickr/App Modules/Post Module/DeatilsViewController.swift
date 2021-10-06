//
//  DeatilsViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - DeatilsViewController

class DeatilsViewController: UITableViewController {
    
    // MARK: - Views Properties
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postIsFavorite: UIButton!
    
    private let postOwnerView: AccountView = .init()
    private let activityIndicator: UIActivityIndicatorView = .init(style: .medium)
    private let skeletonAnimation: SkeletonAnimation = .init()
    
    // MARK: - ViewModel
    
    var viewModel: PostViewModel!
    
    // MARK: - Setup ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

//        postDescription.translatesAutoresizingMaskIntoConstraints = false
//        //tableView.tableHeaderView?.addBottomBorderWithColor(color: .systemGray3, width: 0.5)
//        //tableView.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        setupTableRefreshIndicator()
        setupNextCommentsPageLoadingIndicator()
        setupSkeletonAnimation()
        setupDetailsOwnerView()
        registerReusableCell()
        requestDetails()
    }
    
    private func registerReusableCell() {
        let commentNibName = String(describing: CommentTableViewCell.self)
        let reusableCommentCellNib = UINib(nibName: commentNibName, bundle: Bundle.main)
        tableView.register(reusableCommentCellNib, forCellReuseIdentifier: ReuseIdentifier.commentCell.rawValue)
    }
    
    private enum FavouriteState: String {
        case isFavourite
        case isNotFavourite
        
        var image: UIImage? {
            switch self {
            case .isFavourite: return UIImage(systemName: "bookmark.fill")
            case .isNotFavourite: return UIImage(systemName: "bookmark")
            }
        }
    }
    
    private func requestRemoveFavourite() {
        viewModel.requestRemoveFavourite { [weak self] result in
            switch result {
            case .success:
                self?.postIsFavorite.setImage(FavouriteState.isNotFavourite.image, for: .normal)
            case .failure(let error):
                print("Request to remove post from favourites complete with error: \(error)")
                self?.showAlert(title: "Favourite Error", message: "Request to remove post from favourite failed. Try again.", button: "OK")
            }
        }
    }
    
    private func requestAddFavourite() {
        viewModel.requestAddFavourite { [weak self] result in
            switch result {
            case .success:
                self?.postIsFavorite.setImage(FavouriteState.isFavourite.image, for: .normal)
            case .failure(let error):
                print("Request to add post to favourites complete with error: \(error)")
                self?.showAlert(title: "Favourite Error", message: "Request to add post to favourite failed. Try again.", button: "OK")
            }
        }
    }
    
    private func setupDetailsOwnerView() {
        navigationItem.setHidesBackButton(true, animated: false)
        
        let buttonBack: UIButton = .init(type: .custom)
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .large)
        let buttonBackImage = UIImage(systemName: "chevron.backward", withConfiguration: imageConfiguration)
        
        buttonBack.setImage(buttonBackImage, for: .normal)
        buttonBack.currentImage?.withTintColor(.blue)
        buttonBack.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        buttonBack.sizeToFit()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = .zero
        
        stackView.addArrangedSubview(buttonBack)
        stackView.addArrangedSubview(postOwnerView)
        
        let backButton = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupNextCommentsPageLoadingIndicator() {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
        tableView.tableFooterView = activityIndicator
        activityIndicator.startAnimating()
        tableView.tableFooterView?.isHidden = false
    }
    
    private func setupTableRefreshIndicator() {
        refreshControl = .init()
        refreshControl?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        refreshControl?.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
    }
    
    @IBOutlet weak var postContainer: UIView!
    private func setupSkeletonAnimation() {
        skeletonAnimation.startAnimationFor(view: postOwnerView.ownerAvatar)
        skeletonAnimation.startAnimationFor(view: postOwnerView.ownerAccountName, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: postOwnerView.ownerLocation, cornerRadius: true)
        
        skeletonAnimation.startAnimationFor(view: postImage)
        skeletonAnimation.startAnimationFor(view: postTitle, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: postDescription, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: postDate, cornerRadius: true)
    }
    
    @IBAction func favouriteAction(_ sender: UIButton) {
        viewModel.isFavourite ? requestRemoveFavourite() : requestAddFavourite()
    }
    
    @objc private func backAction() {
        viewModel.close()
    }
    
    @objc private func refreshTable() {
        refreshControl?.beginRefreshing()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
    
    
    
    
    
    
    
    
    
    private var comments: [Post.Comment] = []
    
    
    
    
    
    
    private func requestDetails() {
        viewModel.requestPost { [weak self] result in
            switch result {
            case .success(let post):
                if let avatar = post.owner?.avatar {
                    self?.postOwnerView.ownerAvatar.image = avatar
                }
                
                self?.postOwnerView.ownerAccountName.text = String.prepareAccountName(fullName: post.owner?.realName, username: post.owner?.username)
                
                
                if let location = post.owner?.location {
                    self?.postOwnerView.ownerLocation.text = location
                } else {
                    self?.postOwnerView.ownerLocation.text = "No location"
                }
                
                if let publishedAt = post.publishedAt?.prepareStringAsDate() {
                    self?.postDate.text = publishedAt
                } else {
                    self?.postDate.text = "No date"
                }
                
                self?.postImage.image = post.image
                
                if let title = post.title, !title.isEmpty {
                    self?.postTitle.text = title
                } else {
                    self?.postTitle.text = "No title"
                }
                
                if let description = post.description, !description.isEmpty {
                    self?.postDescription.text = description
                } else {
                    self?.postDescription.text = "No description"
                }
                
                if let comments = post.comments {
                    self?.comments = comments
                }
                
                for _ in 0...5 {
                    self?.comments.append(Post.Comment(owner: Post.Owner(avatar: nil, realName: "John", username: "ash35", location: nil), content: "john_c The game in Japan was amazing and I want to share some photos. The game in Japan was amazing and I want to share some photos", publishedAt: "34 Sep 2000"))
                }
                
                //                if let isFav = post.isFavourite, isFav {
                //                    self?.isFavor = true
                //                    self?.postIsFavorite.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                //                } else {
                //                    self?.isFavor = false
                //                    self?.postIsFavorite.setImage(UIImage(systemName: "bookmark"), for: .normal)
                //                }
                
                self?.tableView.reloadData()
                
                self?.skeletonAnimation.stopAllAnimations()
                self?.tableView.tableHeaderView?.setNeedsLayout()
                self?.tableView.tableHeaderView?.layoutIfNeeded()
                
                
                self?.postContainer.translatesAutoresizingMaskIntoConstraints = false
                self?.postContainer.addBottomBorderWithColor(color: .systemGray3, width: 0.5)
            }
        }
    }
    
    
    
    
    
    
    
    
    

    
    // MARK: - Table DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.commentCell.rawValue) as! CommentTableViewCell
        
        //        var comment: PhotoComment = .init(ownerAvatar: nil, username: comments[indexPath.row].owner?.username, commentContent: comments[indexPath.row].content, publishedAt: comments[indexPath.row].publishedAt)
        var comment: PhotoComment
        if Bool.random() {
            comment = .init(ownerAvatar: nil, username: "samkitty", commentContent: "The game in Japan was amazing and I want to share some photos. The game in Japan was amazing and I want to share some photos", publishedAt: "2135123213")
        } else {
            comment = .init(ownerAvatar: nil, username: "sally69", commentContent: "I want to share some photos! Japan was amazing and I want to share some photos. The game in Japan was amazing and .... I want to share some photos! Japan was amazing and I want to share some photos. The game in Japan was amazing and ....", publishedAt: "2135123213")
        }
        
        
        viewModel.requestOwnerAvatar(index: indexPath.row) { result in
            switch result {
            case .success(let ownerAvatar):
                comment.ownerAvatar = ownerAvatar
            case .failure(let error):
                print("Download owner avatar for comment with index \(indexPath.row) failed. Error: \(error)")
            }
            cell.configure(comment)
        }
        
        cell.configure(comment)
        
        return cell
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            activityIndicator.startAnimating()
            for _ in 0...10 {
                self.comments.append(Post.Comment(owner: Post.Owner(avatar: nil, realName: "John", username: "ash35", location: nil), content: "john_c The game in Japan was amazing and I want to share some photos. The game in Japan was amazing and I want to share some photos", publishedAt: "34 Sep 2000"))
            }
            tableView.reloadData()
        }
    }
    
}


extension UIView {
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}


