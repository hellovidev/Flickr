//
//  HomeViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - HomeViewController

class HomeViewController: UIViewController {

    // MARK: - Properties
    
    var viewModel: HomeViewModel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterStackView: UIStackView!
    
    private let refreshControl: UIRefreshControl = .init()
    private let activityIndicator: UIActivityIndicatorView = .init(style: .medium)

    private func show(_ router: HomeRoute) {
        switch router {
        case .fullPost(id: _):
            let postViewController = Storyboard.main.instantiateViewController(withIdentifier: ReuseIdentifier.postViewController.rawValue) as! PostViewController
            postViewController.viewModel = PostViewModel()
            postViewController.delegate = self
            navigationController?.pushViewController(postViewController, animated: true)
        }
    }
    
    // MARK: - UIViewController Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.router.addObserver { [weak self] router in
            self?.show(router)
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = String(describing: PostTableViewCell.self)
        let reusableCellNib = UINib(nibName: nibName, bundle: nil)
        tableView.register(reusableCellNib, forCellReuseIdentifier: ReuseIdentifier.homePostCell.rawValue)
        
        setupFilterViews()
        requestTableData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.showsVerticalScrollIndicator = false
        
        setupTableRefreshIndicator()
        setupNextPageLoadingIndicator()
        setupNavigationTitle()
    }
    
    // MARK: - Setup UI Methods
    
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
    
    private func setupNavigationTitle() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageName.logotype.rawValue)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        imageView.center = view.convert(view.center, from: imageView);
        view.addSubview(imageView)
        
        navigationItem.titleView = view
    }
    
    private func setupFilterViews() {
        viewModel.filters.forEach {
            let filterView = FilterView()
            filterView.filterImage.backgroundColor = $0.color
            filterView.filterImage.layer.cornerRadius = 8
            filterView.filterName.text = $0.title
            
            let filterAction = UITapGestureRecognizer(target: self, action: #selector(filter))
            filterView.isUserInteractionEnabled = true
            filterView.addGestureRecognizer(filterAction)
            
            filterStackView.addArrangedSubview(filterView)
        }
    }

    @objc
    private func refreshTable() {
        activityIndicator.stopAnimating()
        viewModel.postsNetworkManager.refresh()
        tableView.reloadData()
        requestTableData()
    }
    
    @objc
    private func filter(_ sender: UITapGestureRecognizer) {
        guard let filterName = (sender.view as? FilterView)?.filterName.text else { return }
        guard let filterType = FilterType(rawValue: filterName) else { return }

        viewModel.postsNetworkManager.filter(by: filterType) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func requestTableData() {
        viewModel.postsNetworkManager.requestPostsId { [weak self] result in
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
        return viewModel.postsNetworkManager.idsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.homePostCell.rawValue, for: indexPath) as! PostTableViewCell
        viewModel.requestAndSetupPostIntoTable(tableView: tableView, postCell: cell, indexPath: indexPath)
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
        viewModel.router.send(.fullPost(id: "\(indexPath.row)")) //= .fullPost(id: "\(indexPath.row)")
//        let storyboard = UIStoryboard(name: Storyboard.main.rawValue, bundle: Bundle.main)
//        guard
//            let postViewController = storyboard.instantiateViewController(withIdentifier: ReuseIdentifier.postViewController.rawValue) as? PostViewController
//        else {
//            tableView.deselectRow(at: indexPath, animated: true)
//            return
//        }
//        postViewController.delegate = self
//        navigationController?.pushViewController(postViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - PostViewControllerDelegate

extension HomeViewController: PostViewControllerDelegate {
    
    func close(viewController: PostViewController) {
        navigationController?.popViewController(animated: true)
    }
    
}











//tabBarController?.delegate = self

/*

//???
private var fromAnother: Bool = false


extension HomeViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 && fromAnother == false {
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
*/
