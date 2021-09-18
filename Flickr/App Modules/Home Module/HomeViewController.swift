//
//  HomeViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit
import Combine

// MARK: - HomeViewController

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let activityIndicator: UIActivityIndicatorView = .init(style: .medium)
    private let refreshControl: UIRefreshControl = .init()

    private var postsId: [String] = .init()
    
    var networkService: NetworkService!
    private var pageNumber = 1
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.showsVerticalScrollIndicator = false
        
        // Adding loading view to table view
        activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
        tableView.tableFooterView = activityIndicator
        activityIndicator.startAnimating()
        tableView.tableFooterView?.isHidden = false
        
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc
    private func refresh() {
        pageNumber = 1
        postsId.removeAll()
        activityIndicator.stopAnimating()
        tableView.reloadData()
        networkService.cacheService.removeAll()
        requestListOfPosts(for: pageNumber)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "HomePostCell")
        
        requestListOfPosts(for: pageNumber)
    }
    
    private func requestListOfPosts(for page: Int) {
        networkService.getRecentPosts(page: page) { [weak self] result in
            switch result {
            case .success(let posts):
                guard var postIds = self?.postsId else { return }
                postIds += posts.compactMap { $0.id }
                self?.postsId = postIds.uniques
                

                
                self?.pageNumber += 1
                self?.refreshControl.endRefreshing()
                self?.activityIndicator.stopAnimating()
                
                self?.tableView.reloadData()
            case .failure(let error):
                self?.activityIndicator.stopAnimating()
                self?.tableView.tableFooterView?.isHidden = true
                self?.showAlert(title: "Error", message: error.localizedDescription, button: "OK")
            }
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

extension Array where Element: Hashable {
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePostCell", for: indexPath) as! PostTableViewCell

        networkService?.getPhotoById(with: postsId[indexPath.row]) { [weak self] result in
            switch result {
            case .success(let post):
                // Set current data of post to cell
                //print(post.urls?.url)
        //let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell
                //cell.configure(for: post)
                // Request for buddyicon
                if
                    let iconFarm = post.owner?.iconFarm,
                    let iconServer = post.owner?.iconServer,
                    let nsid = post.owner?.nsid {
                    
                    self?.networkService?.buddyicon(iconFarm: iconFarm, iconServer: iconServer, nsid: nsid) { result in
                        switch result {
                        case .success(let image):
                            let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell
                            cellForRow?.configure(for: post)

                            cellForRow?.setupBuddyIcon(image: image, postId: post.id)
                        case .failure(let error):
                            print("Download buddyicon error: \(error)")
                        }
                    }
                }
                
                // Request for post image
                if
                    let postSecret = post.secret,
                    let serverId = post.server {
                    self?.networkService?.image(postId: post.id, postSecret: postSecret, serverId: serverId) { result in
                        switch result {
                        case .success(let image):
                            let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell
                            cellForRow?.configure(for: post)

                            cellForRow?.setupPostImage(image: image, postId: post.id)
                        case .failure(let error):
                            print("Download image error: \(error)")
                        }
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
        requestListOfPosts(for: pageNumber)

       }
   }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        if indexPath.section == 0 {
////            return UITableView.automaticDimension
////        } else {
//            tableView.setNeedsLayout()
//            tableView.layoutIfNeeded()
//            return UITableView.automaticDimension
//       // }
//    }
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return UITableView.automaticDimension
//        } else {
//            return 40
//        }
//    }
    
    
    
//    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
//        activityIndicator.startAnimating()
//        pageNumber += 1
//        requestListOfPosts(for: pageNumber)
//    }
    
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
