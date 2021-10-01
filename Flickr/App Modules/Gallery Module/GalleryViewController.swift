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
                self?.collectionView.reloadData()
                self?.collectionView.refreshControl?.endRefreshing()
            case .failure(_):
                self?.collectionView.refreshControl?.endRefreshing()
                break
            }
        }
    }
    
    private func setupCollectionRefreshIndicator() {
        let refreshControl: UIRefreshControl = .init()
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        collectionView.refreshControl = refreshControl
        collectionView.addSubview(refreshControl)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.galleryCell.rawValue, for: indexPath)
        

        
        for subview in cell.subviews {
            // you can place "if" condition to remove image view, labels, etc.
            //it will remove subviews of cell's content view
            subview.removeFromSuperview()
        }
        cell.backgroundView = nil
        cell.backgroundColor = nil
        
        if indexPath.row == .zero {
            let newPhotoView: AddButtonView = .init()
            newPhotoView.addNewButton.addTarget(self, action: #selector(onTapAddNewPhoto), for: .touchUpInside)
            newPhotoView.frame = cell.bounds
            cell.addSubview(newPhotoView)
        } else {
            
            
            cell.isUserInteractionEnabled = true
            
            let interaction = UIContextMenuInteraction(delegate: self)
            cell.addInteraction(interaction)
            
            if viewModel.numberOfItems != .zero {
                self.viewModel.requsetPhoto(index: indexPath.row - 1) { result in
                    switch result {
                    case .success(let image):
                        let imageView: UIImageView = .init(image: image)
                        imageView.frame = cell.bounds
                        cell.addSubview(imageView)
                        //cell.backgroundView = imageView
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            cell.backgroundColor = .orange
        }
        //viewModel.getItem(index: indexPath.row)
        return cell
    }
    

    
    
    
    @objc
    private func onTapAddNewPhoto(_ sender: UIButton) {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            
            let photoPicker: PHPickerViewController = .init(configuration: configuration)
            photoPicker.delegate = self
            
            present(photoPicker, animated: true, completion: nil)
        } else {
            let imagePicker: UIImagePickerController = .init()
            imagePicker.delegate = self
            
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true, completion: nil)
            
        }
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
                            print("Delete item with index path \(indexPath) failed with error [\(error)]")
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

































extension GalleryViewController: PHPickerViewControllerDelegate {
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.forEach { result in
            // "public.image"
            //print(result)
            //guard let typeIdentifer = result.itemProvider.registeredTypeIdentifiers.first else { return }
            //print(typeIdentifer)
            result.itemProvider.loadDataRepresentation(forTypeIdentifier: "public.image", completionHandler: { [weak self] data, _ in
                guard let data = data else { return }
                
                self?.viewModel.networkService.uploadNewPhoto(data, title: "New poster", description: "Added photo from iOS application.") { result in
                    switch result {
                    case .success(_):
                        NotificationCenter.default.post(name: Notification.Name("ImageUpload"), object: nil)
                        
                        break
                    case .failure(let error):
                        print(error)
                    }
                }
            })
        }
        
        dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
    }
    
}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        
        if let data = selectedImage.pngData() {
            
            viewModel.networkService.uploadNewPhoto(data, title: "New poster", description: "Added photo from iOS application.") { result in
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: Notification.Name("ImageUpload"), object: nil)
                    
                    break
                case .failure(let error):
                    print(error)
                }
            }
        }
        dismiss(animated: true, completion: nil)
        //        guard let image = info[.editedImage] as? UIImage else { return }
        //
        //        let imageName = UUID().uuidString
        //        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        //
        //        if let jpegData = image.jpegData(compressionQuality: 0.8) {
        //            try? jpegData.write(to: imagePath)
        //        }
        //
        //        dismiss(animated: true)
        
        //        guard let image = info[.editedImage] as? UIImage else {
        //            return self.pickerController(picker, didSelect: nil)
        //        }
    }
    
}




