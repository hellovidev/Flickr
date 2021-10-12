//
//  GalleryRepository.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 03.10.2021.
//

import UIKit

class GalleryRepository {
    
    private var gallery: [Photo]
    
    private var network: NetworkService
    
    private let cacheImages: CacheStorageService<NSString, UIImage>
    
    @UserDefaultsBacked(key: UserDefaults.Keys.nsid.rawValue)
    private var nsid: String!
    
    init(network: NetworkService) {
        self.network = network
        self.cacheImages = .init()
        self.gallery = .init()
    }
    
    func getGallaryCount() -> Int {
        gallery.count
    }
    
    func refresh() {
        cacheImages.removeAll()
    }
    
    func uploadLibraryPhoto(
        data: Data,
        title: String = "Image",
        description: String = "This image uploaded from iOS application.",
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) {
        network.uploadImage(data, title: title, description: description, completion: completionHandler)
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
            case .success:
                self?.gallery.remove(at: index)
                completionHandler(.success(Void()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func removePhotoById(_ id: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        network.deletePhotoById(id, completion: completionHandler)
    }
    
    func requestPhotoLinkInfoArray(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        network.getUserPhotos(for: nsid) { [weak self] result in
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
    
    func requestPhoto(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard
            let id = gallery[index].id,
            let secret = gallery[index].secret,
            let server = gallery[index].server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        let cacheImageIdentifier = id + secret + server as NSString
        if let imageCache = try? cacheImages.get(for: cacheImageIdentifier) {
            completionHandler(.success(imageCache))
            return
        }
        
        network.image(postId: id, postSecret: secret, serverId: server) { result in
            completionHandler(result.map { [weak self] in
                self?.cacheImages.set(for: $0, with: cacheImageIdentifier)
                return $0
            })
        }
    }

    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
