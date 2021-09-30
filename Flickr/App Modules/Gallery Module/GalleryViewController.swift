//
//  GalleryViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit
import PhotosUI

// MARK: - GalleryViewController

class GalleryViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let collectionCellReuseIdentifier: String = "CollectionReusableCell"
    
    var viewModel: GalleryViewModel!

    var refresher:UIRefreshControl!

    @objc
    func loadData() {
        refresher.beginRefreshing()
       //code to execute during refresher

        viewModel.gallery = []
        collectionView.reloadData()
    
        
        viewModel.requestPhotoLinkInfoArray { [weak self] result in
            switch result {
            case .success():
                self?.collectionView.reloadData()
                self?.refresher.endRefreshing()
            case .failure(_):
                break
            }
        }
        
     }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresher = UIRefreshControl()
        self.collectionView.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView.addSubview(refresher)
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        viewModel.requestPhotoLinkInfoArray { [weak self] result in
            switch result {
            case .success():
                self?.collectionView.reloadData()
            case .failure(_):
                break
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(imageUploadNotification), name: Notification.Name("ImageUpload"), object: nil)
        
        

    }
    
    
    
    
    
    
    @objc
    func imageUploadNotification() {
        loadData()
        viewModel.networkService.uploadProgress = 0
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
        return viewModel.numberOfItems != .zero ? viewModel.numberOfItems + 1 : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellReuseIdentifier, for: indexPath)
        
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
            if viewModel.numberOfItems != .zero {
            self.viewModel.requsetPhoto(index: indexPath.row - 1) { result in
                switch result {
                case .success(let image):
                    let imageView: UIImageView = .init(image: image)
                    imageView.frame = cell.bounds
                    cell.backgroundView = imageView
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
    func onTapAddNewPhoto(_ sender: UIButton) {
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

extension GalleryViewController: UIImagePickerControllerDelegate {
    
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
