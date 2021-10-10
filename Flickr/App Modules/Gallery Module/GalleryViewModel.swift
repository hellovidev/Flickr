//
//  GalleryViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

// MARK: - GalleryViewModel

class GalleryViewModel {
    
    private weak var coordinator: GeneralCoordinator?
    
    private let repository: GalleryRepository
    
    init(coordinator: GeneralCoordinator, nsid: String) {
        self.coordinator = coordinator
        self.repository = .init(nsid: nsid)
    }
    
    var numberOfItems: Int {
        repository.getGallaryCount() + 1
    }
    
    func refresh() {
        repository.refresh()
    }
    
    func uploadLibraryPhoto(data: Data, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.uploadLibraryPhoto(data: data, completionHandler: completionHandler)
    }
    
    func removePhotoAt(index: Int, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.removePhotoAt(index: index, completionHandler: completionHandler)
    }
    
    func requestPhotoLinkInfoArray(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        repository.requestPhotoLinkInfoArray(completionHandler: completionHandler)
    }
    
    
    func requestPhoto(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        repository.requestPhoto(index: index, completionHandler: completionHandler)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
    enum DataSourceItem {
        case addNewPhoto
        case galleryPhoto(index: Int)
    }
    
    func itemAt(indexPath: IndexPath) -> DataSourceItem {
        if indexPath.row == 0 {
            return .addNewPhoto
        }
        return .galleryPhoto(index: indexPath.row - 1)
    }
    
}
