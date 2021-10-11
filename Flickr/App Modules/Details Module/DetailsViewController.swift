//
//  DeatilsViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

enum FavouriteState: String {
    case isFavourite
    case isNotFavourite
    
    var image: UIImage? {
        switch self {
        case .isFavourite: return UIImage(systemName: "bookmark.fill")
        case .isNotFavourite: return UIImage(systemName: "bookmark")
        }
    }
}

// MARK: - DeatilsViewController

class DetailsViewController: UITableViewController {
    
    @IBOutlet weak var detailsImage: UIImageView!
    @IBOutlet weak var detailsTitle: UILabel!
    @IBOutlet weak var detailsDescription: UILabel!
    @IBOutlet weak var detailsDate: UILabel!
    @IBOutlet weak var detailsFavourite: UIButton!
    
    // MARK: - Views Properties
    
    private let postOwnerView: AccountView = .init()
    private let skeletonAnimation: SkeletonAnimation = .init()
    
    // MARK: - ViewModel
    
    var viewModel: DetailsViewModel!
    
    // MARK: - Setup ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.separatorStyle = .none
        
        

        setupFavouriteIndicator()
        
        indicatorFavourite.startAnimating()
        detailsFavourite.setImage(nil, for: .normal)
        
        setupTableRefreshIndicator()
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
    
    private func setupTableRefreshIndicator() {
        refreshControl = .init()
        refreshControl?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        refreshControl?.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
    }
    
    private func setupSkeletonAnimation() {
        skeletonAnimation.startAnimationFor(view: postOwnerView.ownerAvatar)
        skeletonAnimation.startAnimationFor(view: postOwnerView.ownerAccountName, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: postOwnerView.ownerLocation, cornerRadius: true)
        
        skeletonAnimation.startAnimationFor(view: detailsImage)
        skeletonAnimation.startAnimationFor(view: detailsTitle, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: detailsDescription, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: detailsDate, cornerRadius: true)
    }
    
    @objc private func backAction() {
        viewModel.close()
    }
    
    @objc private func refreshTable() {
        refreshControl?.beginRefreshing()
        viewModel.refresh()
        tableView.reloadData()
        requestDetails()
    }
    
    private var post: Post?
    
    func requestDetails() {
        viewModel.requestDetails { [weak self] result in
            switch result {
            case .success(let post):
                // Setup Post Owner View
                self?.postOwnerView.ownerAvatar.image = post.owner?.avatar
                self?.postOwnerView.ownerAccountName.text = String.prepareAccountName(fullName: post.owner?.realName, username: post.owner?.username)
                self?.postOwnerView.ownerLocation.text = post.owner?.location == nil ? "No location" : post.owner?.location
                
                if let publishedAt = post.publishedAt?.prepareStringAsDate() {
                    self?.detailsDate.text = publishedAt
                } else {
                    self?.detailsDate.text = "No date"
                }

                self?.detailsImage.image = post.image

                if let title = post.title, !title.isEmpty {
                    self?.detailsTitle.text = title
                } else {
                    self?.detailsTitle.text = "No title"
                }

                if let description = post.description, !description.isEmpty {
                    self?.detailsDescription.text = description
                } else {
                    self?.detailsDescription.text = "No description"
                }
                
                let favouriteStateImage = (post.isFavourite == nil || post.isFavourite == false) ? FavouriteState.isNotFavourite.image : FavouriteState.isFavourite.image
                self?.detailsFavourite.setImage(favouriteStateImage, for: .normal)
                
                self?.post = post
                
                self?.indicatorFavourite.stopAnimating()
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
                self?.skeletonAnimation.stopAllAnimations()
            case .failure(let error):
                print(error)
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
    
    @IBAction func didTapFavourite(_ sender: UIButton) {
        viewModel.isFavourite ? requestRemoveFavourite() : requestAddFavourite()
    }
    
    private var indicatorFavourite: UIActivityIndicatorView!
    private func setupFavouriteIndicator() {
        indicatorFavourite = .init(frame: CGRect(x: 0, y: 0, width: detailsFavourite.frame.width, height: detailsFavourite.frame.height))
        indicatorFavourite.hidesWhenStopped = true
        detailsFavourite.addSubview(indicatorFavourite)
    }
    
    private func requestRemoveFavourite() {
        
        indicatorFavourite.startAnimating()
        detailsFavourite.setImage(nil, for: .normal)
        
            viewModel.requestRemoveFavourite { [weak self] result in
                switch result {
                case .success:
                    self?.indicatorFavourite.stopAnimating()
                    self?.detailsFavourite.setImage(FavouriteState.isNotFavourite.image, for: .normal)
                    //break
                case .failure(let error):
                    self?.indicatorFavourite.stopAnimating()
                    self?.detailsFavourite.setImage(FavouriteState.isFavourite.image, for: .normal)
                    print("Request to remove post from favourites complete with error: \(error)")
                    self?.showAlert(title: "Favourite Error", message: "Request to remove post from favourite failed. Try again.", button: "OK")
                }
            }
        }
    
        private func requestAddFavourite() {
        
            
            indicatorFavourite.startAnimating()
            detailsFavourite.setImage(nil, for: .normal)
            
            viewModel.requestAddFavourite { [weak self] result in
                switch result {
                case .success:
                    self?.indicatorFavourite.stopAnimating()
                    self?.detailsFavourite.setImage(FavouriteState.isFavourite.image, for: .normal)
                    //break
                case .failure(let error):
                    self?.indicatorFavourite.stopAnimating()
                    self?.detailsFavourite.setImage(FavouriteState.isNotFavourite.image, for: .normal)
                    print("Request to add post to favourites complete with error: \(error)")
                    self?.showAlert(title: "Favourite Error", message: "Request to add post to favourite failed. Try again.", button: "OK")
                }
            }
        }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

class DynamicHeaderTableView: UITableView {
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let headerView = self.tableHeaderView else {
            return
        }
        
        let originalSize = self.frame.size
        let targetSize = headerView.systemLayoutSizeFitting(originalSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        if headerView.frame.size.height != targetSize.height {
            headerView.frame.size.height = targetSize.height
            self.tableHeaderView = headerView
            self.layoutIfNeeded()
        }
    }
    
}
