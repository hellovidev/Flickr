//
//  HomeNetworkManager.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.09.2021.
//

import CoreData
import UIKit

// MARK: - HomeRepository

class HomeRepository {
    
    private var network: Network
    
    private let cacheImages: CacheStorageService<NSString, UIImage>
    private let cacheBuddyicons: CacheStorageService<NSString, UIImage>
    private let cachePostInformation: Cache<NSString, PhotoDetailsEntity>
    
    private var ids: [String]
    private var page: Int
    private var perPage: Int
    private var posts: [PhotoDetailsEntity] = .init()
    
    init(network: Network) {
        self.network = network
        
        self.cacheImages = .init()
        self.cacheBuddyicons = .init()
        self.cachePostInformation = .init()
        self.ids = .init()
        self.page = 1
        self.perPage = 20
    }
    
    var idsCount: Int {
        ids.count
    }
    
    func filter(by filterType: FilterType?, completionHandler: @escaping () -> Void) {
        guard let filterType = filterType else {
            perPage = 20
            return
        }
        
        switch filterType {
        case .per50:
            perPage = 50
        case .per100:
            perPage = 100
        case .per200:
            perPage = 200
        case .per400:
            perPage = 400
        }
    }
    
    private func addUniqValues(_ array: [PhotoEntity]) {
        ids += array.compactMap { $0.id }
        ids = ids.uniques
    }
    
    func refresh() {
        page = 1
        ids.removeAll()
        cacheImages.removeAll()
        cacheBuddyicons.removeAll()
        cachePostInformation.removeAll()
    }
    
    func requestPhotosId(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        network.getRecentPosts(page: page, perPage: perPage) { [weak self] result in
            completionHandler(result.map {
                self?.page += 1
                self?.addUniqValues($0)
                return Void()
            })
        }
    }
    
    func requestPhotoDetails(position: Int, group: DispatchGroup, completionHandler: @escaping (Result<PhotoDetailsEntity, Error>) -> Void) {
        group.enter()
        
        let cachePhotoDetailsIdentifier = ids[position] as NSString
        if let photoDetailsCache = cachePostInformation.value(forKey: cachePhotoDetailsIdentifier) {
            completionHandler(.success(photoDetailsCache))
            group.leave()
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let db = DatabaseManager(container: appDelegate.persistentContainer)
        
        network.getPhotoById(for: ids[position]) { [weak self] result in
            completionHandler(result.map {
                db.save(object: $0)
                db.retrive()
                self?.posts.append($0)
                self?.cachePostInformation.insert($0, forKey: cachePhotoDetailsIdentifier)
                group.leave()
                return $0
            })
        }
    }
    
    func requestImage(post: PhotoDetailsEntity, group: DispatchGroup, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        group.enter()
        
        guard
            let id = post.id,
            let secret = post.secret,
            let server = post.server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            group.leave()
            return
        }
        
        let cacheImageIdentifier = id + secret + server as NSString
        if let imageCache = try? cacheImages.get(for: cacheImageIdentifier) {
            completionHandler(.success(imageCache))
            group.leave()
            return
        }
        
        network.image(id: id, secret: secret, server: server) { [weak self] result in
            completionHandler(result.map {
                self?.cacheImages.set(for: $0, with: cacheImageIdentifier)
                group.leave()
                return $0
            })
        }
    }
    
    func requestBuddyicon(post: PhotoDetailsEntity, group: DispatchGroup, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        group.enter()
        
        guard
            let farm = post.owner?.iconFarm,
            let server = post.owner?.iconServer,
            let nsid = post.owner?.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            group.leave()
            return
        }
        
        let cacheBuddyiconIdentifier = String(farm) + server + nsid as NSString
        if let buddyiconCache = try? cacheBuddyicons.get(for: cacheBuddyiconIdentifier) {
            completionHandler(.success(buddyiconCache))
            group.leave()
            return
        }
        
        network.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { [weak self] result in
            completionHandler(result.map {
                self?.cacheBuddyicons.set(for: $0, with: cacheBuddyiconIdentifier)
                group.leave()
                return $0
            })
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
