//
//  HomeViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var networkService: NetworkService?
    private var posts: [PostDetails] = .init()
    private var postsId = [String]()
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
        
        self.tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedPostCell")
        
        //tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "FeedPostCell")
        
        do {
            let token = try StorageService.pull(type: AccessTokenAPI.self, for: "token")
            
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsId.count//1//posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedPostCell", for: indexPath) as! PostTableViewCell
        
        networkService?.getPhotoById(with: postsId[indexPath.row], completion: { result in
            switch result {
            case .success(let photoDetails):
                cell.configure(for: photoDetails)
            case .failure(let error):
                print(error)
            }
        })
        return cell

    }
    
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
