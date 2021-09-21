//
//  HomeViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - HomeViewController

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filtersStackView: UIStackView!
    
    @IBOutlet weak var filterStackView: UIStackView!
    private let refreshControl: UIRefreshControl = .init()
    private let activityIndicator: UIActivityIndicatorView = .init(style: .medium)
    
    var tableNetworkDataManager: NetworkPostInformation!

    //???
    private var fromAnother: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.showsVerticalScrollIndicator = false
        
        setupTableRefreshIndicator()
        setupNextPageLoadingIndicator()
    }
    
    private func setupNextPageLoadingIndicator() {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
        tableView.tableFooterView = activityIndicator
        activityIndicator.startAnimating()
        tableView.tableFooterView?.isHidden = false
    }
    
    private func setupTableRefreshIndicator() {
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
    }
    
    @objc private func refreshTable() {
        activityIndicator.stopAnimating()
        tableNetworkDataManager.refresh()
        tableView.reloadData()
        requestTableData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "FlickrLogotype")
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        imageView.center = view.convert(view.center, from: imageView);
        view.addSubview(imageView)
        
        navigationItem.titleView = view
    }
    
    private func setupStackView() {
//        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
//        scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
//        
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.distribution = .equalSpacing
//        stackView.spacing = 6
//        
//        scrollView.addSubview(stackView)
//        stackView.
    }
    
    struct Filter {
        let image: UIImage
        let title: String
    }
    
    let filters: [String] = ["Faves", "Views", "Comments", "Faves", "Views", "Comments",]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.delegate = self
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "HomePostCell")
        
        requestTableData()
        
        filters.forEach {
            let filterView = FilterView()
            filterView.filterImage.image = UIImage(named: $0)
            filterView.filterImage.layer.cornerRadius = 8
            filterView.filterName.text = $0
            //filterView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            //filterView.widthAnchor.constraint(equalToConstant: 80).isActive = true

            filterStackView.addArrangedSubview(filterView)
            filterStackView.translatesAutoresizingMaskIntoConstraints = false;
            //filterView.topAnchor.constraint(greaterThanOrEqualTo: filtersStackView.topAnchor, constant: 12).isActive = true
            //filterView.topAnchor.constraint(equalTo: filtersStackView.topAnchor, constant: 12).isActive = true
            //filterView.safeAreaInsets.top.constraint(greaterThanOrEqualTo: filtersStackView.safeAreaInsets.top, constant: 12).isActive = true
            //filterView.centerYAnchor.constraint(equalTo: filtersStackView.centerYAnchor).isActive = true
            //filtersStackView.setNeedsLayout()
            //filtersStackView.layoutIfNeeded()
            //filtersStackView.reloadInputViews()
        }
    }
    
    func requestTableData() {
        tableNetworkDataManager.requestPostsId { [weak self] result in
            switch result {
            case .success(_):
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
            case .failure(let error):
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                self?.tableView.tableFooterView?.isHidden = true
                self?.showAlert(title: "Error", message: error.localizedDescription, button: "OK")
            }
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableNetworkDataManager.idsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePostCell", for: indexPath) as! PostTableViewCell
        tableNetworkDataManager.requestPostInformation(position: indexPath.row) { [weak self] result in
            switch result {
            case .success(let postInformation):
                if postInformation.type == .network {
                    if let cellForRow = self?.tableView.cellForRow(at: indexPath) as? PostTableViewCell {
                        cellForRow.configure(for: postInformation.information)
                    } //else {
                       // cell.configure(for: postInformation.information)
                    //}
                } else {
                    cell.configure(for: postInformation.information)
                }
                
                self?.tableNetworkDataManager.requestBuddyicon(post: postInformation.information) { [weak self] result in
                    switch result {
                    case .success(let postBuddyicon):
                        if postBuddyicon.type == .network {
                            if let cellForRow = self?.tableView.cellForRow(at: indexPath) as? PostTableViewCell {
                                cellForRow.setupBuddyicon(image: postBuddyicon.image)
                            } //else {
                              //  cell.setupBuddyicon(image: postBuddyicon.image)
                            //}
                        } else {
                            cell.setupBuddyicon(image: postBuddyicon.image)
                        }

                    case .failure(let error):
                        print("Download buddyicon error: \(error)")
                    }
                }
                
                self?.tableNetworkDataManager.requestImage(post: postInformation.information) { [weak self] result in
                    switch result {
                    case .success(let postImage):
                        if postImage.type == .network {
                            guard let cellForRow = self?.tableView.cellForRow(at: indexPath) as? PostTableViewCell else { return }
                            cellForRow.setupPostImage(image: postImage.image)
                        } else {
                            cell.setupPostImage(image: postImage.image)
                        }
                    case .failure(let error):
                        print("Download image error: \(error)")
                    }
                }
            case .failure(let error):
                print("\(#function) has error: \(error.localizedDescription)")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            activityIndicator.startAnimating()
            requestTableData()
        }
    }
    
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postViewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        postViewController.delegate = self
        navigationController?.pushViewController(postViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - PostViewControllerDelegate

extension HomeViewController: PostViewControllerDelegate {
    
    func close(viewController: PostViewController) {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Network Requests

//extension HomeViewController {
//
//        private func requestPostIds(for page: Int) {
//            manager.network.getRecentPosts(page: page) { [weak self] result in
//                switch result {
//                case .success(let posts):
//                    self?.pageNumber += 1
//
//                    guard var postIds = self?.postsId else { return }
//                    postIds += posts.compactMap { $0.id }
//                    self?.postsId = postIds.uniques
//
//                    self?.refreshControl.endRefreshing()
//                    self?.activityIndicator.stopAnimating()
//                    self?.tableView.reloadData()
//                case .failure(let error):
//                    self?.activityIndicator.stopAnimating()
//                    self?.tableView.tableFooterView?.isHidden = true
//                    self?.showAlert(title: "Error", message: error.localizedDescription, button: "OK")
//                }
//            }
//        }
//
//        private func requestPost(id: String, indexPath: IndexPath, cell: UITableViewCell) {
//            if let cachedPost = try? manager.cache.get(for: id as NSString) {
//                if let cachedPost = cachedPost as? PostDetails {
//                    //if let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
//                    // cellForRow.configure(for: cachedPost)
//                    if let cell = cell as? PostTableViewCell {
//                        cell.configure(for: cachedPost)
//                        // Request buddyicon
//    //                    if let iconFarm = cachedPost.owner?.iconFarm, let iconServer = cachedPost.owner?.iconServer, let nsid = cachedPost.owner?.nsid {
//    //                        self.requestPostBuddyicon(farm: iconFarm, server: iconServer, nsid: nsid, indexPath: indexPath, cell: cell)
//    //                    }
//
//                        // Request post image
//    //                    if let postSecret = cachedPost.secret, let serverId = cachedPost.server {
//    //                        self.requestPostImage(id: cachedPost.id, secret: postSecret, server: serverId, indexPath: indexPath, cell: cell)
//    //                    }
//                        print("Cache: [POST OBJECT][ID: \(id)]")
//                        return
//                    }
//                }
//            }
//
//            manager.network.getPhotoById(with: id) { [weak self] result in
//                switch result {
//                case .success(let post):
//                    self?.manager.cache.set(for: post as AnyObject, with: id as NSString)
//
//                    if let cellForRow = self?.tableView.cellForRow(at: indexPath) as? PostTableViewCell {
//                        cellForRow.configure(for: post)
//
//                        // Request buddyicon
//                        if let iconFarm = post.owner?.iconFarm, let iconServer = post.owner?.iconServer, let nsid = post.owner?.nsid {
//                            self?.requestPostBuddyicon(farm: iconFarm, server: iconServer, nsid: nsid, indexPath: indexPath, cell: cellForRow)
//                        }
//
//                        // Request post image
//                        if let postSecret = post.secret, let serverId = post.server {
//                            self?.requestPostImage(id: post.id, secret: postSecret, server: serverId, indexPath: indexPath, cell: cellForRow)
//                        }
//                    }
//                case .failure(let error):
//                    print("\(#function) has error: \(error.localizedDescription)")
//                }
//            }
//        }
//
//    / - Parameter id: Post id
//    / - Parameter secret: Post secret code
//    / - Parameter server: Post server
//        private func requestPostImage(id: String, secret: String, server: String, indexPath: IndexPath, cell: UITableViewCell) {
//            if let cachedPostImage = try? manager.cache.get(for: id + secret + server as NSString) {
//                if let cachedPostImage = cachedPostImage as? UIImage {
//                    //guard let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell else { return }
//                    //cellForRow.setupPostImage(image: cachedPostImage)
//                    if let cell = cell as? PostTableViewCell {
//                        cell.setupPostImage(image: cachedPostImage)
//                        print("Cache: [POST IMAGE][ID: \(id)]")
//                        return
//                    }
//                }
//            }
//
//            manager.network.image(postId: id, postSecret: secret, serverId: server) { [weak self] result in
//                switch result {
//                case .success(let image):
//                    self?.manager.cache.set(for: image as AnyObject, with: id + secret + server as NSString)
//                    guard let cellForRow = self?.tableView.cellForRow(at: indexPath) as? PostTableViewCell else { return }
//                    cellForRow.setupPostImage(image: image)
//                case .failure(let error):
//                    print("Download image error: \(error)")
//                }
//            }
//        }
//
//        private func requestPostBuddyicon(farm: Int, server: String, nsid: String, indexPath: IndexPath, cell: UITableViewCell) {
//            if let cachedPostBuddyicon = try? manager.cache.get(for: String(farm) + server + nsid as NSString) {
//                if let cachedPostBuddyicon = cachedPostBuddyicon as? UIImage {
//                    //guard let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell else { return }
//                    //cellForRow.setupBuddyicon(image: cachedPostBuddyicon)
//                    if let cell = cell as? PostTableViewCell {
//                        cell.setupBuddyicon(image: cachedPostBuddyicon)
//                        print("Cache: [POST BUDDYICON][NSID: \(nsid)]")
//                        return
//                    }
//                }
//            }
//
//            manager.network.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { [weak self] result in
//                switch result {
//                case .success(let image):
//                    self?.manager.cache.set(for: image as AnyObject, with: String(farm) + server + nsid as NSString)
//                    let cellForRow = self?.tableView.cellForRow(at: indexPath) as? PostTableViewCell
//                    cellForRow?.setupBuddyicon(image: image)
//                case .failure(let error):
//                    print("Download buddyicon error: \(error)")
//                }
//            }
//        }
//
//}

extension HomeViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 && fromAnother == false {
            //tableView.setContentOffset(.zero, animated: true)
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedIndex != 0 {
            fromAnother = true
        } else {
            fromAnother = false
        }
        return true
    }
    
}
