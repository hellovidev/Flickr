//
//  HomeViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - HomeViewController

class HomeViewController: UIViewController {
    
    private var networkService: NetworkService?
    private var postsId: [String] = .init()
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        //tableView.estimatedRowHeight = 800
        
        self.tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "HomePostCell")
        
        do {
            let token = try UserDefaultsStorageService.pull(type: AccessTokenAPI.self, for: "token")
            
            networkService = .init(
                accessTokenAPI: token,
                publicConsumerKey: FlickrConstant.Key.consumerKey.rawValue,
                secretConsumerKey: FlickrConstant.Key.consumerSecretKey.rawValue
            )
            
            requestListOfPosts()
        } catch {
            showAlert(title: "Error", message: error.localizedDescription, button: "OK")
        }
    }
    
    private func requestListOfPosts() {
        networkService?.getRecentPosts { [weak self] result in
            switch result {
            case .success(let posts):
                self?.postsId = posts.compactMap { $0.id }
                self?.tableView.reloadData()
            case .failure(let error):
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
        return postsId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePostCell", for: indexPath) as! PostTableViewCell
        
        networkService?.getPhotoById(with: postsId[indexPath.row]) { [weak self] result in
            switch result {
            case .success(let post):
                // Set current data of post to cell
                cell.configure(for: post)
                
                // Request for buddyicon
                if
                    let iconFarm = post.owner?.iconFarm,
                    let iconServer = post.owner?.iconServer,
                    let nsid = post.owner?.nsid {
                    
                    self?.networkService?.buddyicon(iconFarm: iconFarm, iconServer: iconServer, nsid: nsid) { result in
                        switch result {
                        case .success(let image):
                            cell.setupBuddyIcon(image: image, postId: post.id)
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
                            cell.setupPostImage(image: image, postId: post.id)
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
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cell = cell as! PostTableViewCell
//
//
//    }
    
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postViewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        postViewController.delegate = self
        navigationController?.pushViewController(postViewController, animated: true)
    }
    
}

// MARK: - PostViewControllerDelegate

extension HomeViewController: PostViewControllerDelegate {
    
    func close(viewController: PostViewController) {
        navigationController?.popViewController(animated: true)
    }
    
}
