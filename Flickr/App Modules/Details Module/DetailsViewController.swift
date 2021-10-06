//
//  DeatilsViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - DeatilsViewController

class DetailsViewController: UITableViewController {
    
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
    
    var viewModel: DetailsViewModel!
    
    // MARK: - Setup ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView?.addBottomBorderWithColor(color: .systemGray3, width: 0.5)
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
        viewModel.refresh()
        requestDetails()
    }
    
    private func requestDetails() {
        viewModel.requestPost { [weak self] result in
            switch result {
            case .success(let post):
                // Setup Post Owner View
                self?.postOwnerView.ownerAvatar.image = post.owner?.avatar
                self?.postOwnerView.ownerAccountName.text = String.prepareAccountName(fullName: post.owner?.realName, username: post.owner?.username)
                self?.postOwnerView.ownerLocation.text = post.owner?.location == nil ? "No location" : post.owner?.location
                
                // Setup Post Image
                self?.postImage.image = post.image
                
                // Setup Post Description
                self?.postTitle.text = (post.title == nil || ((post.title?.isEmpty) != nil)) ? "No title" : post.title
                self?.postDescription.text = (post.description == nil || ((post.description?.isEmpty) != nil)) ? "No description" : post.description
                self?.postDate.text = post.publishedAt?.prepareStringAsDate()

                // Setup Favourite Icon
                let favouriteStateImage = (post.isFavourite == nil || post.isFavourite == false) ? FavouriteState.isNotFavourite.image : FavouriteState.isFavourite.image
                self?.postIsFavorite.setImage(favouriteStateImage, for: .normal)
                
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
                self?.activityIndicator.stopAnimating()
                self?.skeletonAnimation.stopAllAnimations()
            case .failure(let error):
                print(error) //????
            }
        }
    }
    
    private func requestNextComments() {
        viewModel.requestNextComments { [weak self] result in
            //self?.activityIndicator.stopAnimating()
            switch result {
            case .success:
                self?.tableView.reloadData()
            case .failure(let error):
                print("Load comments request failed with error: \(error)")
                self?.showAlert(title: "Comments Load Error", message: "Load comments request failed. Try again after refresh page.", button: "OK")
            }
        }
    }
    
    // MARK: - Table DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfComments
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.commentCell.rawValue) as! CommentTableViewCell
        
        viewModel.commentForRowAt(index: indexPath.row) { comment in
            cell.configure(comment)
        }
        
        return cell
    }
    
    // MARK: - Table Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let lastSectionIndex = tableView.numberOfSections - 1
//        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 3
//
//        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
//            activityIndicator.startAnimating()
//            requestNextComments()
//        }
//    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        activityIndicator.stopAnimating()
        requestNextComments()
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
