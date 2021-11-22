//
//  GalleryViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit
import PhotosUI

// MARK: - GalleryViewController

class GalleryViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: GalleryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(GalleryCollectionReusableCell.self, forCellWithReuseIdentifier: ReuseIdentifier.galleryCell.rawValue)
        
        setupNavigationTitle()
        setupCollectionRefreshIndicator()
        
        viewModel.updateWithLoadedData = {
            self.collectionView.reloadData()
        }
        
        requestPhotos()
    }
    
    @objc private func refreshCollectionView() {
        viewModel.refreshGallery { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.collectionView.refreshControl?.endRefreshing()
            }
            switch result {
            case .success:
                self?.collectionView.reloadData()
            case .failure(let error):
                self?.showAlert(
                    title: "Gallery Error",
                    message: "Refresh gallery photos failed.\nTry to check your internet connection and pull to refresh.",
                    button: "OK"
                )
                print("Refresh gallery error: \(error)")
            }
        }
    }
    
    private func requestPhotos() {
        collectionView.refreshControl?.beginRefreshing()
        viewModel.initialRetriveUserPhotos { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.collectionView.refreshControl?.endRefreshing()
            }
            switch result {
            case .success:
                self?.collectionView.reloadData()
            case .failure(let error):
                self?.showAlert(
                    title: "Gallery Error",
                    message: "Loading gallery photos failed.\nTry to check your internet connection and pull to refresh.",
                    button: "OK"
                )
                print("Request gallery error: \(error)")
            }
        }
    }
    
    private func setupCollectionRefreshIndicator() {
        let refreshControl: UIRefreshControl = .init()
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
    }
    
    private func setupNavigationTitle() {
        let navigationLogotype: NavigationLogotype = .init()
        navigationItem.titleView = navigationLogotype
    }
    
    @objc private func onTapAddButtonAction(_ sender: UIButton) {
        let picker: UIViewController
        if #available(iOS 14, *) {
            picker = configurePhotoPicker()
        } else {
            picker = configureImagePicker()
        }
        present(picker, animated: true, completion: nil)
    }
    
    @available(iOS 14, *)
    private func configurePhotoPicker() -> PHPickerViewController {
        var configuration: PHPickerConfiguration = .init()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let photoPicker: PHPickerViewController = .init(configuration: configuration)
        photoPicker.delegate = self
        
        return photoPicker
    }
    
    private func configureImagePicker() -> UIImagePickerController {
        let imagePicker: UIImagePickerController = .init()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        return imagePicker
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.galleryCell.rawValue, for: indexPath) as! GalleryCollectionReusableCell
        
        switch viewModel.itemAt(indexPath: indexPath) {
        case .uploadPhoto:
            let buttonView: UploadButtonView = .init()
            buttonView.uploadPhotoButton.addTarget(self, action: #selector(onTapAddButtonAction), for: .touchUpInside)
            cell.view = buttonView
        case .galleryPhoto(index: let index):
            let interaction = UIContextMenuInteraction(delegate: self)
            cell.interaction = interaction
            
            self.viewModel.retriveUserPhoto(index: index) { result in
                switch result {
                case .success(let image):
                    let imageView: UIImageView = .init(image: image)
                    cell.view = imageView
                case .failure(let error):
                    print("Request photo error: \(error)")
                }
            }
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewCell

class GalleryCollectionReusableCell: UICollectionViewCell {
    
    var view: UIView = .init() {
        didSet {
            view.frame = self.bounds
            view.contentMode = .scaleAspectFill
            self.clipsToBounds = true
            self.addSubview(view)
        }
    }
    
    var interaction: UIContextMenuInteraction? {
        didSet {
            guard let interaction = interaction else { return }
            self.addInteraction(interaction)
        }
    }
    
    override func prepareForReuse() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        self.interactions.removeAll()
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSideSize = calculateCellSideSize()
        return CGSize(width: cellSideSize, height: cellSideSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let numberOfItemsInSection: CGFloat = CGFloat(collectionView.numberOfItems(inSection: .zero))
        guard numberOfItemsInSection == 1 else { return .zero }
        
        let cellSideSize = calculateCellSideSize()
        
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let totalSpacingWidth = collectionViewFlowLayout.minimumInteritemSpacing * numberOfItemsInSection
        let totalWidth = cellSideSize * numberOfItemsInSection
        
        let rightInset = collectionView.frame.width - (totalWidth + totalSpacingWidth)
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset)
    }
    
    private func calculateCellSideSize(cellColumns: CGFloat = 3) -> CGFloat {
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let inset = collectionViewFlowLayout.minimumInteritemSpacing * (cellColumns - 1)
        let cellSideSize = (collectionView.bounds.width - inset) / cellColumns
        
        return round(cellSideSize)
    }
    
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch viewModel.itemAt(indexPath: indexPath) {
        case .uploadPhoto:
            break
        case .galleryPhoto(index: _):
            animateOpacity(view: cell)
        }
    }
    
    private func animateOpacity(view: UIView) {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true
        view.layer.add(animation, forKey: "fade")
    }
    
}

// MARK: - UIContextMenuInteractionDelegate

extension GalleryViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        // Building item of menu
        let removeIcon = UIImage(systemName: "trash")
        let removeItem = UIAction(title: "Delete", image: removeIcon, attributes: .destructive) { [weak self] action in
            
            // Getting IndexPath of pressed item and do action
            let item = interaction.location(in: self?.collectionView)
            guard let indexPath = self?.collectionView.indexPathForItem(at: item) else { return }
            
            let activitiyIndicator: ActivityViewController = .init()
            self?.present(activitiyIndicator, animated: true)
            
            guard let index = self?.viewModel.itemAt(indexPath: indexPath) else { return }
            switch index {
            case .uploadPhoto:
                break
            case .galleryPhoto(index: let index):
                self?.viewModel.deleteUserPhoto(index: index) { [weak self] result in
                    switch result {
                    case .success:
                        self?.collectionView.deleteItems(at: [indexPath])
                    case .failure(let error):
                        self?.showAlert(
                            title: "Delete Failed",
                            message: "Failed to delete photo.\nTry again.",
                            button: "OK"
                        )
                        print("Delete item with index path \(indexPath.row) failed with error [\(error)]")
                    }
                    self?.dismiss(animated: true)
                }
            }
        }
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let menu = UIMenu(title: "", options: .displayInline, children: [removeItem])
            return menu
        }
        
        return configuration
    }
    
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if
            let selectedImage = info[.originalImage] as? UIImage,
            let data = selectedImage.pngData()
        {
            self.viewModel.uploadUserPhoto(data: data) { [weak self] result in
                switch result {
                case .success:
                    self?.refreshCollectionView()
                case .failure(let error):
                    self?.showAlert(
                        title: "Upload Failed",
                        message: "Failed to upload photo to flickr.\nTry to check your internet connection and try again.",
                        button: "OK"
                    )
                    print("Upload image error: \(error)")
                }
            }
        }
        dismiss(animated: true)
    }
    
}

// MARK: - PHPickerViewControllerDelegate

extension GalleryViewController: PHPickerViewControllerDelegate {
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.forEach { result in
            result.itemProvider.loadDataRepresentation(forTypeIdentifier: "public.image") { [weak self] data, _ in
                guard let data = data else {
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true)
                    }
                    return
                }
                
                self?.viewModel.uploadUserPhoto(data: data) { [weak self] result in
                    switch result {
                    case .success:
                        self?.refreshCollectionView()
                    case .failure(let error):
                        self?.showAlert(
                            title: "Upload Failed",
                            message: "Failed to upload photo to flickr.\nTry to check your internet connection and try again.",
                            button: "OK"
                        )
                        print("Upload image error: \(error)")
                    }
                }
            }
        }
        
        dismiss(animated: true)
    }
    
}
