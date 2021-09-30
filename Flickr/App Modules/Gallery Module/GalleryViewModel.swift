//
//  GalleryViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

class GalleryViewModel {
    
    var gallery: [Photo] = .init()
    
    var numberOfItems: Int {
        gallery.count
    }
    
    func getItem(index: Int) -> Photo? {
        return gallery[index]
    }
    
    let networkService: NetworkService
    let nsid: String
    init(nsid: String, networkService: NetworkService) {
        self.networkService = networkService
        self.nsid = nsid
    }
    
    func requestPhotoLinkInfoArray(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        networkService.getUserPhotos(for: nsid) { [weak self] result in
            switch result {
            case .success(let photoRequestInfoArray):
                self?.gallery = photoRequestInfoArray
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
