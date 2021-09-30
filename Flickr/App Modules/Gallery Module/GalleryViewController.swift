//
//  GalleryViewController.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 05.09.2021.
//

import UIKit

// MARK: - GalleryViewController

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let collectionCellReuseIdentifier: String = "CollectionReusableCell"
    
    var viewModel: GalleryViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return viewModel.numberOfItems + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellReuseIdentifier, for: indexPath)
        
        if indexPath.row == .zero {
            let addNewButtonView = AddButtonView()
            addNewButtonView.frame = cell.bounds
            cell.backgroundView = addNewButtonView
//            let stackView = UIStackView()
//            stackView.distribution = .equalSpacing
//            stackView.axis = .vertical
//            stackView.center = cell.convert(cell.center, from: stackView)
//
//            let button = UIButton()
//            stackView.addArrangedSubview(button)
//            cell.backgroundView = stackView
//
//            button.widthAnchor.constraint(equalTo: button.heightAnchor, constant: 64).isActive = true

            //button.frame = cell.bounds
//            button.layer.cornerRadius = button.frame.width / 2
//            button.layer.borderWidth = 1
//            button.layer.borderColor = UIColor.gray.cgColor
//            button.backgroundColor = .orange
            
//            let lableButton = UILabel(frame: CGRect(x: 0, y: 0, width: stackView.frame.width, height: 0))
//            lableButton.text = "New"
//
//            stackView.addArrangedSubview(lableButton)
            //cell.backgroundView = button
            //cell.backgroundColor = .black
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
