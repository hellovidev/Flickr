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
    
    private let galleryNetworkManager: GalleryNetworkManager
    
    init(coordinator: GeneralCoordinator, nsid: String, networkService: NetworkService) {
        self.coordinator = coordinator
        self.galleryNetworkManager = .init(nsid: nsid, networkService: networkService)
    }
    
    var numberOfItems: Int {
        galleryNetworkManager.getGallaryCount()
    }
    
    func removeAll() {
        galleryNetworkManager.removeAll()
    }
    
    func uploadLibraryPhoto(data: Data, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        galleryNetworkManager.uploadLibraryPhoto(data: data, completionHandler: completionHandler)
    }
    
    func removePhotoAt(index: Int, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        galleryNetworkManager.removePhotoAt(index: index, completionHandler: completionHandler)
    }
    
    func requestPhotoLinkInfoArray(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        galleryNetworkManager.requestPhotoLinkInfoArray(completionHandler: completionHandler)
    }
    
    
    func requsetPhoto(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        galleryNetworkManager.requsetPhoto(index: index, completionHandler: completionHandler)
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
