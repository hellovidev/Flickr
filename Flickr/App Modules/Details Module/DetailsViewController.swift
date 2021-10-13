//
//  DeatilsViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - DeatilsViewController

class DetailsViewController: UITableViewController {
    
    @IBOutlet weak var detailsImage: UIImageView!
    @IBOutlet weak var detailsTitle: UILabel!
    @IBOutlet weak var detailsDescription: UILabel!
    @IBOutlet weak var detailsDate: UILabel!
    @IBOutlet weak var detailsFavourite: UIButton!
    
    // MARK: - Views Properties
    
    private let detailsAuthor: AccountView = .init()
    private let skeletonAnimation: SkeletonAnimation = .init()
    private let indicatorFavourite: UIActivityIndicatorView = .init()
    
    // MARK: - ViewModel
    
    var viewModel: DetailsViewModel!
    
    // MARK: - Setup ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupTableSeparator()
        setupFavouriteIndicator()
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
        stackView.addArrangedSubview(detailsAuthor)
        
        let backButton = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupTableRefreshIndicator() {
        refreshControl = .init()
        refreshControl?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        refreshControl?.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
    }
    
    private func setupSkeletonAnimation() {
        skeletonAnimation.startAnimationFor(view: detailsAuthor.ownerAvatar)
        skeletonAnimation.startAnimationFor(view: detailsAuthor.ownerAccountName, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: detailsAuthor.ownerLocation, cornerRadius: true)
        
        skeletonAnimation.startAnimationFor(view: detailsImage)
        skeletonAnimation.startAnimationFor(view: detailsTitle, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: detailsDescription, cornerRadius: true)
        skeletonAnimation.startAnimationFor(view: detailsDate, cornerRadius: true)
    }
    
    private func setupTableSeparator() {
        tableView.separatorStyle = .none
    }
    
    
    private func setupFavouriteIndicator() {
        indicatorFavourite.frame = detailsFavourite.bounds// .init(frame: CGRect(x: 0, y: 0, width: detailsFavourite.frame.width, height: detailsFavourite.frame.height))
        indicatorFavourite.hidesWhenStopped = true
        detailsFavourite.addSubview(indicatorFavourite)
        
        indicatorFavourite.startAnimating()
        detailsFavourite.setImage(nil, for: .normal)
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
    
    private func stopAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.indicatorFavourite.stopAnimating()
            self?.refreshControl?.endRefreshing()
        }
    }
    
    func requestDetails() {
        viewModel.requestDetails { [weak self] result in
            //self?.refreshControl?.endRefreshing()
            switch result {
            case .success(let post):
                // Setup Post Owner View
                self?.skeletonAnimation.stopAllAnimations()
                
                self?.detailsAuthor.ownerAvatar.image = post.owner?.avatar
                
                
                self?.detailsAuthor.ownerAccountName.text = PrepareTextFormatter.prepareUserAccountName(name: post.owner?.realName, username: post.owner?.username)
                
                // Setup location
                let location = PrepareTextFormatter.prepareTextField(post.owner?.location, placeholder: .location)
                self?.detailsAuthor.ownerLocation.text = location

                // Setup title
                let title = PrepareTextFormatter.prepareTextField(post.title, placeholder: .title)
                self?.detailsTitle.text = title
                
                // Setup description
                let description = PrepareTextFormatter.prepareTextField(post.description, placeholder: .description)
                self?.detailsDescription.text = description

                // Setup date
                let dateAsString = post.publishedAt?.prepareStringAsDate()
                let date = PrepareTextFormatter.prepareTextField(dateAsString, placeholder: .date)
                self?.detailsDate.text = date
                
                self?.detailsImage.image = post.image
                
                let favouriteStateImage = (post.isFavourite == nil || post.isFavourite == false) ? FavouriteState.isNotFavourite.image : FavouriteState.isFavourite.image
                self?.detailsFavourite.setImage(favouriteStateImage, for: .normal)
                
                self?.post = post
                self?.tableView.reloadData()

            case .failure(let error):
                print(error)
                self?.showAlert(
                    title: "Refresh Error",
                    message: "Loading details about post failed.\nTry to check your internet connection and pull to refresh.",
                    button: "OK"
                )
            }
            self?.stopAnimations()
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
    
    @IBAction func didTapFavourite(_ sender: UIButton) {
        viewModel.isFavourite ? requestRemoveFavourite() : requestAddFavourite()
    }
    

    
    private func requestRemoveFavourite() {
        
        indicatorFavourite.startAnimating()
        detailsFavourite.setImage(nil, for: .normal)
        
            viewModel.requestRemoveFavourite { [weak self] result in
                self?.indicatorFavourite.stopAnimating()

                switch result {
                case .success:
                    self?.detailsFavourite.setImage(FavouriteState.isNotFavourite.image, for: .normal)
                    //break
                case .failure(let error):
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
                self?.indicatorFavourite.stopAnimating()
                switch result {
                case .success:
                    self?.detailsFavourite.setImage(FavouriteState.isFavourite.image, for: .normal)
                    //break
                case .failure(let error):
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

// MARK: - DynamicHeaderTableView

class DynamicHeaderTableView: UITableView {
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let tableHeaderView = self.tableHeaderView else {
            return
        }
        
        let originalSize = self.frame.size
        let targetSize = tableHeaderView.systemLayoutSizeFitting(originalSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        if tableHeaderView.frame.size.height != targetSize.height {
            tableHeaderView.frame.size.height = targetSize.height
            self.tableHeaderView = tableHeaderView
            self.layoutIfNeeded()
        }
    }
    
}
