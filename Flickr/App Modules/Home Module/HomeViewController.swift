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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterStackView: UIStackView!
    
    private let refreshControl: UIRefreshControl = .init()
    private let activityIndicator: UIActivityIndicatorView = .init(style: .medium)
    
    private let connectivity: InternetConnectivity = .init()
    private var filterButtons: [UIButton] = .init()
    
    var viewModel: HomeViewModel!
    
    // MARK: - UIViewController Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        connectivity.startMonitoring()
        
        setupTableRefreshIndicator()
        setupNextPageLoadingIndicator()
        setupNavigationTitle()
        setupFilterViews()
        setupTableCellHeight()
        
        registerTableReusableCell()
        
        requestTableData()
    }
    
    // MARK: - Setup UI Methods
    
    private func setupTableCellHeight() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
    }
    
    private func registerTableReusableCell() {
        let nibName = String(describing: PhotoDetailsTableViewCell.self)
        let reusableCellNib = UINib(nibName: nibName, bundle: nil)
        tableView.register(reusableCellNib, forCellReuseIdentifier: ReuseIdentifier.homeCell.rawValue)
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
    
    private func setupNavigationTitle() {
        let navigationLogotype: NavigationLogotype = .init()
        navigationItem.titleView = navigationLogotype
    }
    
    private func setupFilterViews() {
        viewModel.filters.forEach {
            let filterButton = UIButton(type: .custom)
            
            let filterButtonTextAttributes: [NSAttributedString.Key : Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let text = NSAttributedString(string: $0, attributes: filterButtonTextAttributes)
            filterButton.setAttributedTitle(text, for: .normal)
            
            filterButton.backgroundColor = .systemBlue
            filterButton.layer.cornerRadius = 8
            filterButton.contentHorizontalAlignment = .left
            filterButton.contentVerticalAlignment = .bottom
            filterButton.titleEdgeInsets.left = 10
            
            filterButton.addTarget(self, action: #selector(filter), for: .touchUpInside)
            filterButtons.append(filterButton)
            filterStackView.addArrangedSubview(filterButton)
        }
    }
    
    @objc private func refreshTable() {        
        activityIndicator.stopAnimating()
        viewModel.refresh()
        tableView.reloadData()
        requestTableData()
    }
    
    @objc private func filter(_ sender: UIButton) {
        var filterType: FilterType? = nil
        let selectedState = sender.isSelected
        
        filterButtons.forEach {
            $0.isSelected = false
            $0.backgroundColor = .systemBlue
        }
        
        if !selectedState {
            sender.isSelected = true
            sender.backgroundColor = .systemPink
            guard let filterName = sender.currentAttributedTitle?.string else { return }
            filterType = FilterType(rawValue: filterName)
        }
        
        viewModel.filter(by: filterType) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func requestTableData() {
        viewModel.requestPhotosId { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.refreshControl.endRefreshing()
            }
            self?.activityIndicator.stopAnimating()
            switch result {
            case .success:
                self?.tableView.reloadData()
            case .failure(let error):
                self?.tableView.tableFooterView?.isHidden = true
                self?.showAlert(title: "Home Error", message: "Something went wrong. Please try again.", button: "OK")
                print("Photos download failed: \(error)")
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
        return viewModel.numberOfIds
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.homeCell.rawValue, for: indexPath) as! PhotoDetailsTableViewCell
        cell.isUserInteractionEnabled = false
        
        viewModel.requestPhotoDetailsCell(indexPath: indexPath) { details, buddyicon, image  in
            tableView.beginUpdates()
            cell.configuration(details: details, buddyicon: buddyicon, image: image)
            cell.isUserInteractionEnabled = true
            tableView.endUpdates()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if connectivity.isReachable {
            let lastSectionIndex = tableView.numberOfSections - 1
            let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            
            if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
                activityIndicator.startAnimating()
                requestTableData()
            }
        }
    }
    
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PhotoDetailsTableViewCell
        guard let id = cell.photoDetailsId else { return }
        
        viewModel.openDetails(id: id)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
