//
//  HomeViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - HomeViewController

class HomeViewController: UIViewController {
    
    let filters: [String] = ["Faves", "Views", "Comments", "Faves", "Views", "Comments",]

    //???
    private var fromAnother: Bool = false
    
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filtersStackView: UIStackView!
    
    @IBOutlet weak var filterStackView: UIStackView!
    private let refreshControl: UIRefreshControl = .init()
    private let activityIndicator: UIActivityIndicatorView = .init(style: .medium)
    
    var tableNetworkDataManager: NetworkPostInformation!
    
    // MARK: - UIViewController Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.delegate = self
        
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
        filters.forEach {
            let filterView = FilterView()
            filterView.filterImage.image = UIImage(named: $0)
            filterView.filterImage.layer.cornerRadius = 8
            filterView.filterName.text = $0
            
            let filterAction = UITapGestureRecognizer(target: self, action: #selector(filter))
            filterView.isUserInteractionEnabled = true
            filterView.addGestureRecognizer(filterAction)
            
            filterStackView.addArrangedSubview(filterView)
        }
    }

    @objc
    private func refreshTable() {
        activityIndicator.stopAnimating()
        tableNetworkDataManager.refresh()
        tableView.reloadData()
        requestTableData()
    }
    
    @objc
    private func filter(_ sender: UITapGestureRecognizer) {
        guard let filterName = (sender.view as? FilterView)?.filterName.text else { return }
        guard let filterType = FilterType(rawValue: filterName) else { return }

        tableNetworkDataManager.filter(by: filterType) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func requestTableData() {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.homePostCell.rawValue, for: indexPath) as! PostTableViewCell
        tableNetworkDataManager.requestAndSetupPostIntoTable(tableView: tableView, postCell: cell, indexPath: indexPath)
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
        let storyboard = UIStoryboard(name: Storyboard.main.rawValue, bundle: Bundle.main)
        guard
            let postViewController = storyboard.instantiateViewController(withIdentifier: ReuseIdentifier.postViewController.rawValue) as? PostViewController
        else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
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
