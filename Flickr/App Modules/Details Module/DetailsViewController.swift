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
        indicatorFavourite.frame = detailsFavourite.bounds
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
        requestDetails()
    }
    
    private func stopAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.indicatorFavourite.stopAnimating()
            self?.refreshControl?.endRefreshing()
        }
    }
    
    private func requestDetails() {
        //setupSkeletonAnimation()
        viewModel.requestDetails { [weak self] result in
            self?.stopAnimations()
            
            switch result {
            case .success(let details):
                self?.detailsAuthor.ownerAvatar.image = details.owner?.avatar
                
                let ownerAccountName = PrepareTextFormatter.prepareUserAccountName(name: details.owner?.realName, username: details.owner?.username)
                self?.detailsAuthor.ownerAccountName.text = ownerAccountName
                
                let ownerLocation = PrepareTextFormatter.prepareTextField(details.owner?.location, placeholder: .location)
                self?.detailsAuthor.ownerLocation.text = ownerLocation
                
                self?.detailsImage.image = details.image
                
                let title = PrepareTextFormatter.prepareTextField(details.title, placeholder: .title)
                self?.detailsTitle.text = title
                
                let description = PrepareTextFormatter.prepareTextField(details.description, placeholder: .description)
                self?.detailsDescription.text = description
                
                let dateAsString = details.publishedAt?.prepareStringAsDate()
                let date = PrepareTextFormatter.prepareTextField(dateAsString, placeholder: .date)
                self?.detailsDate.text = date
                
                let isFavourite = details.isFavourite == nil || details.isFavourite == false
                let favouriteStateImage = isFavourite ? FavouriteState.isNotFavourite.image : FavouriteState.isFavourite.image
                self?.detailsFavourite.setImage(favouriteStateImage, for: .normal)
                
                self?.skeletonAnimation.stopAllAnimations()
                self?.tableView.reloadData()
            case .failure(let error):
                self?.skeletonAnimation.stopAllAnimations()
                self?.showAlert(
                    title: "Refresh Error",
                    message: "Loading details about post failed.\nTry to check your internet connection and pull to refresh.",
                    button: "OK"
                )
                print("Details request failed: \(error)")
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
            case .failure(let error):
                print("Request to remove post from favourites complete with error: \(error)")
                self?.detailsFavourite.setImage(FavouriteState.isFavourite.image, for: .normal)
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
            case .failure(let error):
                print("Request to add post to favourites complete with error: \(error)")
                self?.detailsFavourite.setImage(FavouriteState.isNotFavourite.image, for: .normal)
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
