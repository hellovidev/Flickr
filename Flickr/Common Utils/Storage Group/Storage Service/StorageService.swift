//
//  StorageService.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/9/21.
//

import UIKit

public struct DomainPhotoDetails {
    var details: PhotoDetailsEntity?
    var image: UIImage?
    var buddyicon: UIImage?
}

public class StorageService {
    
    private let network: Network!
    private let database: CoreDataManager!
    private let connection: InternetConnectivity!
    
    private let cacheImages: Cache<String, UIImage>
    private let cacheBuddyicons: Cache<String, UIImage>
    private let cachePostDetails: Cache<String, PhotoDetailsEntity>
    
    init(network: Network, database: CoreDataManager, connection: InternetConnectivity) {
        self.network = network
        self.database = database
        self.connection = connection
        
        self.cacheImages = .init()
        self.cacheBuddyicons = .init()
        self.cachePostDetails = .init()
        
        self.connection.startMonitoring()
    }
    
    public func requestArrayPhotoDetailsIds(page: Int, per: Int, completionHandler: @escaping (Result<[String], Error>) -> Void) {
        if connection.isReachable {
            network.getRecentPosts(page: page, perPage: per) { result in
                completionHandler(result.map { array in
                    let ids = array.map {
                        $0.id!
                    }
                    return ids
                })
            }
        } else {
            do {
                let ids = try database.fetchIDs()
                completionHandler(.success(ids))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    public func requestPhotoDetailsById(id: String, completionHandler: @escaping (Result<DomainPhotoDetails, Error>) -> Void) {
        if connection.isReachable {
            let group = DispatchGroup()
            
            var details: PhotoDetailsEntity?
            var image: UIImage?
            var buddyicon: UIImage?
            
            networkRequestPhotoDetails(id: id, group: group) { [weak self] result in
                switch result {
                case .success(let photoDetails):
                    details = photoDetails
                    
                    self?.networkGroupRequestImagesOfPhotoDetails(details: photoDetails, group: group) { photo, avatar in
                        buddyicon = avatar
                        image = photo
                        
                        DispatchQueue.main.async {
                            if let photoDetails = details {
                                self?.database?.save(object: photoDetails, image: image?.pngData(), avatar: buddyicon?.pngData())
                            }
                            let domainEntity = DomainPhotoDetails(details: details, image: image, buddyicon: buddyicon)
                            completionHandler(.success(domainEntity))
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        let domainEntity = DomainPhotoDetails(details: details, image: image, buddyicon: buddyicon)
                        completionHandler(.success(domainEntity))
                    }
                    print("Download photo details cell in \(#function) has error: \(error)")
                }
            }
        } else {
            let object = database?.fetchById(id: id)
            let domainEntity = DomainPhotoDetails(details: object?.details, image: object?.image, buddyicon: object?.buddyicon)
            completionHandler(.success(domainEntity))
        }
    }
    
    private func networkGroupRequestImagesOfPhotoDetails(details: PhotoDetailsEntity, group: DispatchGroup, completionHandler: @escaping (_ photo: UIImage?, _ avatar: UIImage?) -> Void) {
        var avatar: UIImage?
        var photo: UIImage?
        
        networkRequestBuddyicon(details: details, group: group) { result in
            switch result {
            case .success(let image):
                avatar = image
            case .failure(let error):
                print("Download buddyicon error: \(error)")
            }
        }
        
        networkRequestImage(details: details, group: group) { result in
            switch result {
            case .success(let image):
                photo = image
            case .failure(let error):
                print("Download image error: \(error)")
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completionHandler(photo, avatar)
        }
    }
    
    private func networkRequestImage(details: PhotoDetailsEntity, group: DispatchGroup, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        group.enter()
        
        guard
            let id = details.id,
            let secret = details.secret,
            let server = details.server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            group.leave()
            return
        }
        
        let cacheImageIdentifier = id + secret + server
        if let imageCache = cacheImages.value(forKey: cacheImageIdentifier) {
            completionHandler(.success(imageCache))
            group.leave()
            return
        }
        
        network.image(id: id, secret: secret, server: server) { [weak self] result in
            completionHandler(result.map {
                self?.cacheImages.insert($0, forKey: cacheImageIdentifier)
                group.leave()
                return $0
            })
        }
    }
    
    private func networkRequestBuddyicon(details: PhotoDetailsEntity, group: DispatchGroup, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        group.enter()
        
        guard
            let farm = details.owner?.iconFarm,
            let server = details.owner?.iconServer,
            let nsid = details.owner?.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            group.leave()
            return
        }
        
        let cacheBuddyiconIdentifier = String(farm) + server + nsid
        if let buddyiconCache = cacheBuddyicons.value(forKey: cacheBuddyiconIdentifier) {
            completionHandler(.success(buddyiconCache))
            group.leave()
            return
        }
        
        network.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { [weak self] result in
            completionHandler(result.map {
                self?.cacheBuddyicons.insert($0, forKey: cacheBuddyiconIdentifier)// set(for: $0, with: cacheBuddyiconIdentifier)
                group.leave()
                return $0
            })
        }
    }
    
    private func networkRequestPhotoDetails(id: String, group: DispatchGroup, completionHandler: @escaping (Result<PhotoDetailsEntity, Error>) -> Void) {
        group.enter()
        
        if let photoDetailsCache = cachePostDetails.value(forKey: id) {
            completionHandler(.success(photoDetailsCache))
            group.leave()
            return
        }
        
        network.getPhotoById(for: id) { [weak self] result in
            completionHandler(result.map {
                self?.cachePostDetails.insert($0, forKey: id)
                group.leave()
                return $0
            })
        }
    }
    
    deinit {
        connection.stopMonitoring()
        print("\(type(of: self)) deinited.")
    }
    
}
