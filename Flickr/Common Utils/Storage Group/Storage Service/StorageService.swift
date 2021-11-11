//
//  StorageService.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/9/21.
//

import UIKit

public struct DomainPhotoDetails {
    
    public var details: PhotoDetailsEntity?
    public var imagePath: String?
    public var buddyiconPath: String?
}

public extension DomainPhotoDetails {
    public init(details: PhotoDetailsEntity) {
        self.details = details
    }
}

public class StorageService {
    
    private let network: Network
    private let database: CoreDataManager
    private let connection: InternetConnectivity
    
    
//    private let cacheImages: Cache<String, UIImage>
//    private let cacheBuddyicons: Cache<String, UIImage>
    private let cachePostDetails: Cache<String, PhotoDetailsEntity>
    
    var postArray: [DomainPhotoDetails] = .init()
    
    private let imageDataManager: ImageDataManager
    
    init(network: Network, database: CoreDataManager, connection: InternetConnectivity) {
        self.network = network
        self.database = database
        self.connection = connection
        
//        self.cacheImages = .init()
//        self.cacheBuddyicons = .init()
        self.cachePostDetails = .init()
        
        self.connection.startMonitoring()
        
        if self.connection.isReachable {
            try! self.database.clearDatabase()
        }
        
        imageDataManager = try! .init(name: "FlickrImages")

    }
    
    public func refreshStorage() {
        do {
            try database.clearDatabase()
            try imageDataManager.deleteAllImageData()
            
//            cacheImages.removeAll()
//            cacheBuddyicons.removeAll()
            cachePostDetails.removeAll()
        } catch {
            print("Refresh failed")
        }
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
                let objects = try database.fetchSetOfObjects()
                postArray = objects
                
                let ids = objects.map {
                    $0.details!.id!
                }
                completionHandler(.success(ids))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    public func requestPhotoDetailsById(id: String, completionHandler: @escaping (_ details: PhotoDetailsEntity?, _ buddyicon: UIImage?, _ image: UIImage?) -> Void) {
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
                                let imagePath = try! self?.imageDataManager.saveImageData(data: image!.pngData()!, forKey: details!.id!)
                                let buddyiconPath = try! self?.imageDataManager.saveImageData(data: image!.pngData()!, forKey: details!.owner!.nsid!)
                                let domainEntity = DomainPhotoDetails(details: details, imagePath: imagePath, buddyiconPath: buddyiconPath)
                                try! self?.database.saveObject(object: domainEntity)
                            }
                            completionHandler(details, buddyicon, image)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completionHandler(details, image, buddyicon)
                    }
                    print("Download photo details cell in \(#function) has error: \(error)")
                }
            }
        } else {
            
            let object = postArray.first(where: {
                $0.details?.id == id
            })
            
            do {
                //let object = try database.fetchObjectById(id: id)
                let imageData = try imageDataManager.fetchImageData(filePath: object!.imagePath!)
                let buddyiconData = try imageDataManager.fetchImageData(filePath: object!.buddyiconPath!)
                guard let buddyicon = UIImage(data: buddyiconData), let image = UIImage(data: imageData) else {
                    completionHandler(object?.details, nil, nil)
                    return
                }
                completionHandler(object?.details, buddyicon, image)
            } catch {
                print(error)
                completionHandler(nil, nil, nil)
            }
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
        
        let imageIdentifier = id + secret + server
        if let imageData = try? imageDataManager.fetchImageData(forKey: imageIdentifier) {
            guard let image = UIImage(data: imageData) else {
                completionHandler(.failure(ImageError.couldNotInit))
                return
            }
            completionHandler(.success(image))
            group.leave()
            return
        }
        
        network.image(id: id, secret: secret, server: server) { result in
            group.leave()
            
            switch result {
            case .success(let imageData):

                    guard let image = UIImage(data: imageData) else {
                        completionHandler(.failure(ImageError.couldNotInit))
                        return
                    }
                    completionHandler(.success(image))

            case .failure(let error):
                completionHandler(.failure(error))
        }
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
        
        let buddyiconIdentifier = String(farm) + server + nsid
        if let buddyiconData = try? imageDataManager.fetchImageData(forKey: buddyiconIdentifier) {
            guard let buddyicon = UIImage(data: buddyiconData) else {
                completionHandler(.failure(ImageError.couldNotInit))
                return
            }
            completionHandler(.success(buddyicon))
            group.leave()
            return
        }
        
        network.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { result in
            group.leave()
            
            switch result {
            case .success(let buddyiconData):
                    guard let buddyicon = UIImage(data: buddyiconData) else {
                        completionHandler(.failure(ImageError.couldNotInit))
                        return
                    }
                    completionHandler(.success(buddyicon))
            case .failure(let error):
                completionHandler(.failure(error))
        }
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
