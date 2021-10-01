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
        
        collectionView.register(GalleryCollectionReusableCell.self, forCellWithReuseIdentifier: "GalleryCollectionReusableCell")
        
        setupNavigationTitle()
        setupCollectionRefreshIndicator()
        
        requestPhotos()
        
        // Add observer to image upload completion
        NotificationCenter.default.addObserver(self, selector: #selector(imageUploadNotification), name: Notification.Name("ImageUpload"), object: nil) // ???
    }
    
    @objc
    private func refreshCollectionView() {
        viewModel.gallery = [] // ???
        collectionView.reloadData()
        requestPhotos()
    }
    
    @objc
    private func imageUploadNotification() {
        refreshCollectionView()
        viewModel.networkService.uploadProgress = 0 // ???
    }
    
    private func requestPhotos() {
        collectionView.refreshControl?.beginRefreshing()
        viewModel.requestPhotoLinkInfoArray { [weak self] result in
            switch result {
            case .success():
                self?.collectionView.refreshControl?.endRefreshing()
                self?.collectionView.reloadData()
            case .failure(_):
                self?.collectionView.refreshControl?.endRefreshing()
                self?.showAlert(
                    title: "Gallery Error",
                    message: "Loading gallery photos failed.\nTry to check your internet connection and pull to refresh.",
                    button: "OK"
                )
                break
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
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageName.logotype.rawValue)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        imageView.center = view.convert(view.center, from: imageView);
        view.addSubview(imageView)
        
        navigationItem.titleView = view
    }
    
    @objc
    private func onTapAddButtonAction(_ sender: UIButton) {
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
        return viewModel.numberOfItems > .zero ? viewModel.numberOfItems + 1 : .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.galleryCell.rawValue, for: indexPath) as! GalleryCollectionReusableCell
        
        if indexPath.row == .zero {
            let buttonView: AddButtonView = .init()
            buttonView.addNewButton.addTarget(self, action: #selector(onTapAddButtonAction), for: .touchUpInside)
            cell.view = buttonView
        } else {
            let interaction = UIContextMenuInteraction(delegate: self)
            cell.interaction = interaction
            
            self.viewModel.requsetPhoto(index: indexPath.row - 1) { result in
                switch result {
                case .success(let image):
                    let imageView: UIImageView = .init(image: image)
                    cell.view = imageView
                case .failure(let error):
                    print("Photo loading error: \(error)")
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
        let width = collectionView.bounds.width
        
        let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let inset = collectionViewFlowLayout?.sectionInset.top
        let insetCell = collectionViewFlowLayout?.minimumInteritemSpacing
        let cellCount: CGFloat = 3
        let targetWidth: CGFloat = (width - inset! * CGFloat(2) - insetCell! * CGFloat(3)) / cellCount
        return CGSize(width:  targetWidth, height: targetWidth)
    }
    
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // ...
    }
    
}

// MARK: - UIContextMenuInteractionDelegate

extension GalleryViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] actions -> UIMenu? in
            
            // Building item of menu
            let removeIcon = UIImage(systemName: "trash")
            let removeItem = UIAction(title: "Delete", image: removeIcon, attributes: .destructive) { [weak self] action in
                
                // Getting IndexPath of pressed item and do action
                let item = interaction.location(in: self?.collectionView)
                if let indexPath = self?.collectionView.indexPathForItem(at: item) {
                    self?.viewModel.removePhotoAt(index: indexPath.row - 1) { [weak self] result in
                        switch result {
                        case .success():
                            self?.collectionView.deleteItems(at: [indexPath])
                        case .failure(let error):
                            print("Delete item with index path \(indexPath.row) failed with error [\(error)]")
                        }
                    }
                } else {
                    print("Couldn't find index path")
                }
            }
            
            let menu = UIMenu(title: "", options: .displayInline, children: [removeItem])
            return menu
        }
        
        return configuration
    }
    
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if
            let selectedImage = info[.originalImage] as? UIImage,
            let data = selectedImage.pngData()
        {
            self.viewModel.uploadLibraryPhoto(data: data) { [weak self] result in
                switch result {
                case .success():
                    NotificationCenter.default.post(name: Notification.Name("ImageUpload"), object: nil) // ???
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
        results.forEach { [weak self] result in
            
            result.itemProvider.loadDataRepresentation(forTypeIdentifier: "public.image") { [weak self] data, _ in
                guard let data = data else {
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true)
                    }
                    return
                }
                
                self?.viewModel.uploadLibraryPhoto(data: data) { [weak self] result in
                    switch result {
                    case .success():
                        NotificationCenter.default.post(name: Notification.Name("ImageUpload"), object: nil) // ???
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
