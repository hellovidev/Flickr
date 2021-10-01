//
//  GalleryViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

// MARK: - GalleryViewModel

class GalleryViewModel {
    
    private var gallery: [Photo] = .init()
    
    private let networkService: NetworkService
    
    private let userId: String
    
    var numberOfItems: Int {
        gallery.count
    }
    
    func refresh() {
        gallery.removeAll()
    }
    
    init(nsid: String, networkService: NetworkService) {
        self.networkService = networkService
        self.userId = nsid
    }
    
    func uploadLibraryPhoto(
        data: Data,
        title: String = "Image",
        description: String = "This image uploaded from iOS application.",
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) {
        networkService.uploadImage(data, title: title, description: description) { result in
            switch result {
            case .success():
                completionHandler(.success(Void()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func removePhotoAt(index: Int, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        guard
            let id = gallery[index].id
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        removePhotoById(id) { [weak self] result in
            switch result {
            case .success():
                self?.gallery.remove(at: index)
                completionHandler(.success(Void()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func removePhotoById(_ id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        networkService.deletePhotoById(id, completion: completionHandler)
    }
    
    func requestPhotoLinkInfoArray(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        networkService.getUserPhotos(for: userId) { [weak self] result in
            switch result {
            case .success(let photoArray):
                self?.gallery = photoArray
                completionHandler(.success(Void()))
            case .failure(let error):
                completionHandler(.failure(error))
                break
            }
        }
    }
    
    func requsetPhoto(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard
            let id = gallery[index].id,
            let secret = gallery[index].secret,
            let server = gallery[index].server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        networkService.image(postId: id, postSecret: secret, serverId: server) { result in
            completionHandler(result.map { $0 })
        }
    }
    
}
