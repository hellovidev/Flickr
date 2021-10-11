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
    
    // MARK: - Views Properties
    
    private let postOwnerView: AccountView = .init()
    private let skeletonAnimation: SkeletonAnimation = .init()
    
    // MARK: - ViewModel
    
    var viewModel: DetailsViewModel!
    
    // MARK: - Setup ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.tableHeaderView?.addBottomBorderWithColor(color: .systemGray3, width: 0.5)
        setupTableRefreshIndicator()
        setupSkeletonAnimation()
        setupDetailsOwnerView()
        registerReusableCell()
        
        tableView.separatorStyle = .none
        requestDetails()
    }
    
    private func registerReusableCell() {
        let commentNibName = String(describing: CommentTableViewCell.self)
        let reusableCommentCellNib = UINib(nibName: commentNibName, bundle: Bundle.main)
        tableView.register(reusableCommentCellNib, forCellReuseIdentifier: ReuseIdentifier.commentCell.rawValue)
        
        let detailsNibName = String(describing: DetailsTableViewCell.self)
        let reusableDetailsCellNib = UINib(nibName: detailsNibName, bundle: Bundle.main)
        tableView.register(reusableDetailsCellNib, forCellReuseIdentifier: ReuseIdentifier.detailsCell.rawValue)
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
                
                self?.post = post
                
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
        switch viewModel.itemAt(indexPath: indexPath) {
        case .detailsInformation:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.detailsCell.rawValue) as! DetailsTableViewCell
            
            if let post = self.post {
                tableView.beginUpdates()
                cell.configure(details: post)
                tableView.endUpdates()
                cell.delegate = self
            }
            
            return cell
        case .detailsComment(index: let index):
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.commentCell.rawValue) as! CommentTableViewCell
            
            viewModel.commentForRowAt(index: index) { comment in
                cell.configure(comment)
            }
            
            return cell
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

extension DetailsViewController: DetailsCellDelegate {
    
    func didClickFavourite(_ cell: DetailsTableViewCell) {
        viewModel.isFavourite ? requestRemoveFavourite(button: cell.detailsFavourite) : requestAddFavourite(button: cell.detailsFavourite)
    }
    
    private func requestRemoveFavourite(button: UIButton) {
        button.setImage(FavouriteState.isNotFavourite.image, for: .normal)
            viewModel.requestRemoveFavourite { [weak self] result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    button.setImage(FavouriteState.isFavourite.image, for: .normal)
                    print("Request to remove post from favourites complete with error: \(error)")
                    self?.showAlert(title: "Favourite Error", message: "Request to remove post from favourite failed. Try again.", button: "OK")
                }
            }
        }
    
        private func requestAddFavourite(button: UIButton) {
            button.setImage(FavouriteState.isFavourite.image, for: .normal)
            viewModel.requestAddFavourite { [weak self] result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    button.setImage(FavouriteState.isNotFavourite.image, for: .normal)
                    print("Request to add post to favourites complete with error: \(error)")
                    self?.showAlert(title: "Favourite Error", message: "Request to add post to favourite failed. Try again.", button: "OK")
                }
            }
        }
    
}
